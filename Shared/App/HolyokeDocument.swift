//
//  HolyokeDocument.swift
//  Shared
//
//  Created by Brian Yu on 6/8/22.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var pgnType: UTType {
        UTType(filenameExtension: "pgn", conformingTo: .text)!
    }
}

final class HolyokeDocument: ReferenceFileDocument, ObservableObject {
    
    @Published var games: [PGNGame]
    @Published var currentGameIndex: Int {
        willSet(newGameIndex) {
            if !self.games.indices.contains(currentGameIndex) {
                return
            }
            self.gameCurrentNodes[self.games[currentGameIndex].id] = self.currentNode
        }
        didSet {
            if !self.games.indices.contains(currentGameIndex) {
                return
            }
            
            let currentGame = self.games[currentGameIndex]
            let newCurrentNode = self.gameCurrentNodes[currentGame.id] ?? currentGame.root
            self.resetChessboardToNode(node: newCurrentNode)
        }
    }
    @Published var currentNode: PGNGameNode
    
    // Mapping from game IDs to the current node in each game
    var gameCurrentNodes: [Int: PGNGameNode]

    init() {
        let games = PGNGameListener.parseGamesFromPGNString(pgn: "")
        let currentGameIndex = 0
        
        self.games = games
        self.currentGameIndex = currentGameIndex
        self.currentNode = games[currentGameIndex].root
        self.gameCurrentNodes = [:]
        self.currentNode.chessboard = games[currentGameIndex].startingPosition
        self.currentNode.setPlayerToMove(playerToMove: self.currentNode.chessboard!.playerToMove)
    }

    static var readableContentTypes: [UTType] { [.pgnType] }
    
    var currentGame: PGNGame { games[currentGameIndex] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        let games = PGNGameListener.parseGamesFromPGNString(pgn: string)
        let currentGameIndex = 0
        
        self.games = games
        self.currentGameIndex = currentGameIndex
        self.currentNode = games[currentGameIndex].root
        self.gameCurrentNodes = [:]
        self.currentNode.chessboard = games[currentGameIndex].startingPosition
        self.currentNode.setPlayerToMove(playerToMove: self.currentNode.chessboard!.playerToMove)
    }
    
    func snapshot(contentType: UTType) throws -> [PGNGame] {
        return self.games
    }
    
    func fileWrapper(snapshot: [PGNGame], configuration: WriteConfiguration) throws -> FileWrapper {
        var text = ""
        for game in snapshot {
            text += game.generatePGNText()
            text += "\n"
        }
        let data = text.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }

    // Gameplay
    
    func makeMoveOnBoard(move: Move) {
        guard let chessboard = currentNode.chessboard else {
            return
        }
        
        // Find move notation for the move
        var moveNotation: String? = nil
        for (notation, legalMove) in chessboard.legalMoves {
            if move == legalMove {
                moveNotation = notation
            }
        }
        
        // If it's not a valid move, don't allow the move to be made
        guard let moveNotation = moveNotation else {
            return
        }

        // Check if the move is already one of the variations in the game tree
        var nextNode: PGNGameNode? = nil
        for variation in currentNode.variations {
            if variation.move == moveNotation {
                nextNode = variation
            }
        }
        
        if let nextNode = nextNode {
            // Found next move node, make it the current node
            currentNode.setSelectedVariation(variation: nextNode)
            currentNode = nextNode
            if currentNode.chessboard == nil {
                currentNode.chessboard = chessboard.getChessboardAfterMove(move: move)
            }
        } else {
            // Add the move as a new variation to the current node, make it the new current node
            let newNode = currentNode.addNewVariation()
            newNode.move = moveNotation
            currentNode.setSelectedVariation(variation: newNode)
            
            currentNode = newNode
            if currentNode.chessboard == nil {
                currentNode.chessboard = chessboard.getChessboardAfterMove(move: move)
            }
        }
    }
    
    func forceManualRefresh() {
        objectWillChange.send()
    }
    
    // Controls
    
    func resetChessboardToNode(node: PGNGameNode) {
        
        // If we already have the board saved, no need for any more computation
        if node.chessboard != nil {
            currentNode = node
            return
        }
        
        // Otherwise, we need to compute the position
        var nodes: [PGNGameNode] = []
        
        // Loop through nodes to get to parent
        var cursor: PGNGameNode? = node
        while (cursor != nil) {
            nodes.append(cursor!)
            cursor = cursor!.parent
        }
        
        var board = self.currentGame.startingPosition
        for node in nodes.reversed() {
            if node.moveNumber == 0 {
                continue
            }
            if let parent = node.parent {
                parent.setSelectedVariation(variation: node)
            }
            guard let move = board.legalMoves[node.move ?? ""] else {
                break
            }
            board = board.getChessboardAfterMove(move: move)
        }
        node.chessboard = board
        currentNode = node
        
    }
    
    func updateCurrentNodeToNextMove() {
        guard let chessboard = currentNode.chessboard else {
            return
        }
        
        // If there are no more moves to make, return
        if currentNode.variations.count == 0 {
            return
        }
        
        // If there's a selected variation, make sure it's valid
        if currentNode.selectedVariationIndex ?? 0 >= currentNode.variations.count {
            currentNode.selectedVariationIndex = nil
        }
        
        let variation = currentNode.variations[currentNode.selectedVariationIndex ?? 0]
        guard let move = chessboard.legalMoves[variation.move ?? ""] else {
            return
        }
        currentNode = variation
        currentNode.chessboard = chessboard.getChessboardAfterMove(move: move)
    }
    
    func updateCurrentNodeToPreviousMove() {
        // If there's no previous move, stop
        guard let node = currentNode.parent else {
            return
        }
        
        self.resetChessboardToNode(node: node)
    }
    
    func updateCurrentNodeToNextVariation() {
        // Move needs a parent
        guard let parent = currentNode.parent else {
            return
        }
        
        // Needs multiple variations to work
        if parent.variations.count == 1 {
            return
        }
        
        let nextVariationIndex = (parent.selectedVariationIndex ?? 0) + 1
        
        if nextVariationIndex < parent.variations.count {
            self.resetChessboardToNode(node: parent.variations[nextVariationIndex])
        }
    }
    
    func updateCurrentNodeToPreviousVariation() {
        // Move needs a parent
        guard let parent = currentNode.parent else {
            return
        }
        
        // Needs multiple variations to work
        if parent.variations.count == 1 {
            return
        }
        
        let previousVariationIndex = (parent.selectedVariationIndex ?? 0) - 1
        
        if previousVariationIndex >= 0 {
            self.resetChessboardToNode(node: parent.variations[previousVariationIndex])
        }
    }
    
    func deleteCurrentNode() {
        // Move needs a parent
        guard let parent = currentNode.parent else {
            self.currentNode.selectedVariationIndex = nil
            self.currentNode.variations = []
            self.forceManualRefresh()
            return
        }
        
        let nodeToDelete = self.currentNode
        
        self.currentNode = parent
        parent.setSelectedVariation(variation: nodeToDelete)
        if let index = parent.selectedVariationIndex {
            parent.variations.remove(at: index)
            parent.selectedVariationIndex = parent.variations.isEmpty ? nil : max(index - 1, 0)
        }
    }
    
    func deleteGameById(gameId: Int) {
        // There must always be at least one game
        if self.games.count <= 1 {
            return
        }
        
        // Find the game to delete
        var gameIndex: Int? = nil
        for (i, game) in self.games.enumerated() {
            if game.id == gameId {
                gameIndex = i
                break
            }
        }
        guard let gameIndex = gameIndex else {
            return
        }
        
        let newCurrentGameIndex = self.currentGameIndex >= gameIndex ? max(self.currentGameIndex - 1, 0) : self.currentGameIndex
        let _ = self.gameCurrentNodes.removeValue(forKey: gameId)
        self.games.remove(at: gameIndex)
        self.currentGameIndex = newCurrentGameIndex

    }
    
    func deleteCurrentGame() {
        self.deleteGameById(gameId: self.currentGame.id)
    }
    
    func createNewGame(undoManager: UndoManager?) {
        let game = PGNGame()
        let chessboard = Chessboard.initInStartingPosition()
        game.root.chessboard = chessboard
        game.root.setPlayerToMove(playerToMove: chessboard.playerToMove)
        self.games.append(game)
        self.currentGameIndex = self.games.count - 1
        self.currentNode = game.root
        
        guard let undoManager = undoManager else {
            return
        }
        
        print("Undo manager is here!")
        
        undoManager.registerUndo(withTarget: self, handler: { document in
            print("Deleting the newly created game...")
            // Don't delete the game if it has moves
            if game.root.variations.count > 0 {
                return
            }
            document.deleteGameById(gameId: game.id)
        })
    }
}
