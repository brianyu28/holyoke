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
    @Published var chessboard: Chessboard
    @Published var currentNode: PGNGameNode

    init() {
        let games = PGNGameListener.parseGamesFromPGNString(pgn: "")
        self.games = games
        self.chessboard = Chessboard.initInStartingPosition()
        self.currentNode = games[0].root
    }

    static var readableContentTypes: [UTType] { [.pgnType] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        let games = PGNGameListener.parseGamesFromPGNString(pgn: string)
        self.games = games
        self.chessboard = Chessboard.initInStartingPosition()
        self.currentNode = games[0].root
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
            currentNode = nextNode
            chessboard = chessboard.getChessboardAfterMove(move: move)
        } else {
            // Add the move as a new variation to the current node, make it the new current node
            let newNode = currentNode.addNewVariation()
            newNode.move = moveNotation
            currentNode = newNode
            chessboard = chessboard.getChessboardAfterMove(move: move)
        }
    }
    
    // Controls
    
    func resetChessboardToNode(node: PGNGameNode) {
        var nodes: [PGNGameNode] = []
        
        // Loop through nodes to get to parent
        var cursor: PGNGameNode? = node
        while (cursor != nil) {
            nodes.append(cursor!)
            cursor = cursor!.parent
        }
        
        var board = Chessboard.initInStartingPosition()
        for node in nodes.reversed() {
            if node.moveNumber == 0 {
                continue
            }
            guard let move = board.legalMoves[node.move ?? ""] else {
                break
            }
            board = board.getChessboardAfterMove(move: move)
        }
        chessboard = board
        currentNode = node
        
    }
    
    func nextMove() {
        
        // If there are no more moves to make, return
        if currentNode.variations.count == 0 {
            return
        }
        
        // TODO: allow selecting a variation based on the currently selected line
        let variation = currentNode.variations[0]
        guard let move = chessboard.legalMoves[variation.move ?? ""] else {
            return
        }
        currentNode = variation
        chessboard = chessboard.getChessboardAfterMove(move: move)
    }
    
    func previousMove() {
        // If there's no previous move, stop
        guard let node = currentNode.parent else {
            return
        }
        
        self.resetChessboardToNode(node: node)
    }
}
