//
//  DocumentState.swift
//  Holyoke
//
//  Created by Brian Yu on 6/22/22.
//

import Foundation

/**
 Object representing the current state of the document viewer/editor.
 The document itself holds only the game data, whereas `DocumentState` holds information about the state of the app.
 */
class DocumentState: ObservableObject {
    /**
     The document that is being viewed.
     */
    var document: HolyokeDocument
    
    /**
     The index of the currently active game in the document.
     */
    @Published var currentGameIndex: Int {
        // When updating the currently selected game, store its current node in case we switch back.
        willSet(newGameIndex) {
            // If the game index is no longer part of the document, then no action
            if !document.games.indices.contains(currentGameIndex) {
                return
            }
            let game = document.games[currentGameIndex]
            self.currentGameNodes[game.id] = self.currentNode
        }
        
        // After the game index has been updated, make sure the current node reflects the new game
        didSet {
            // Only update if the game index is actually valid
            if !document.games.indices.contains(currentGameIndex) {
                return
            }
            
            let newNode = self.currentGameNodes[currentGame.id] ?? currentGame.root
            self.currentNode = newNode
        }
    }
    
    /**
     The currently active node, must be a node in the current game.
     */
    @Published var currentNode: PGNGameNode {
        // Before setting a new node as current, make sure we've computed the chessboard for it
        willSet(newNode) {
            if newNode.parent == nil {
                // If there is no parent, then the position should be the starting position of the game
                newNode.setChessboardForNode(board: self.currentGame.startingPosition)
            } else {
                // Otherwise, we can compute the position for the new node
                newNode.computeChessboardForNode()
            }
        }
    }
    
    /**
     Mapping from `PGNGameNode` IDs to the index of their selected variation.
     */
    @Published var selectedVariationIndices: [Int: Int]
    
    /**
     Mapping from `PGNGame` IDs to the current node in each game.
     */
    var currentGameNodes: [Int: PGNGameNode]
    
    /**
     The currently active game in the document.
     */
    var currentGame: PGNGame { document.games[currentGameIndex] }
    
    /**
     Initialize the document viewer.
     */
    init(document: HolyokeDocument) {
        let currentGameIndex = 0
        
        self.document = document
        self.currentGameIndex = currentGameIndex
        self.currentNode = document.games[currentGameIndex].root
        self.selectedVariationIndices = [:]
        self.currentGameNodes = [:]
        self.currentNode.setChessboardForNode(board: self.currentGame.startingPosition)
    }
    
    /**
     Force a manual refresh of the observed object.
     */
    func forceManualRefresh() {
        objectWillChange.send()
    }
    
    /**
     An example document state using an empty document, for testing.
     */
    static var sampleDocumentState: DocumentState { DocumentState(document: HolyokeDocument()) }
    
    // Gameplay Controls
    
    /**
     Make a move from the position given by the current node.
     This updates the current node to be the position after making the move.
     If the move wasn't already a variation of the current node, it is added as a variation to the current node.
     
     - Parameters:
        - move: The move to make.
     */
    func makeMoveFromCurrentNode(move: Move) {
        
        // Ensure that the current node has a chessboard
        guard let chessboard = self.currentNode.chessboard else {
            return
        }
        
        // Ensure that the move is a legal move in the position
        let moveNotation: String? = {
            for (notation, legalMove) in chessboard.legalMoves {
                if move == legalMove {
                    return notation
                }
            }
            return nil
        }()
        guard let moveNotation = moveNotation else {
            return
        }
        
        // Check to see if the move is already a variation
        let variation: (index: Int, node: PGNGameNode)? = {
            for (i, variation) in self.currentNode.variations.enumerated() {
                if variation.move == moveNotation {
                    return (index: i, node: variation)
                }
            }
            return nil
        }()
        
        // Update the current node
        if let variation = variation {
            // The variation already exists, update the current node
            self.selectedVariationIndices[self.currentNode.id] = variation.index
            self.currentNode = variation.node
        } else {
            // The variation doesn't exist, create a new node for it
            let newNode = self.currentNode.addNewVariation()
            newNode.move = moveNotation
            self.selectedVariationIndices[self.currentNode.id] = self.currentNode.variations.indices.last
            self.currentNode = newNode
        }
    }
    
    /**
     Change the current node to be the next node in the variation.
     */
    func updateCurrentNodeToNextMove() {
        // There must be a next move to update to
        if self.currentNode.variations.count == 0 {
            return
        }
        
        // Get the next variation index, or 0 if not specified
        let nextVariationIndex: Int = {
            guard let variationIndex = self.selectedVariationIndices[self.currentNode.id] else {
                return 0
            }
            if !self.currentNode.variations.indices.contains(variationIndex) {
                return 0
            }
            return variationIndex
        }()
        
        // Update the current node
        self.currentNode = self.currentNode.variations[nextVariationIndex]
    }
    
    /**
     Change the current node to be the previous node in the variation.
     */
    func updateCurrentNodeToPreviousMove() {
        // There must be a parent node to update to
        guard let parent = self.currentNode.parent else {
            return
        }
        self.currentNode = parent
    }
    
    /**
     Change the current node to be the variation offset by a particular offset.
     
     - Parameters:
        - offset: How many variations to shift by. 1 for next variation, -1 for previous variation.
     */
    private func updateCurrentNodeToVariationOffsetBy(offset: Int) {
        // There must be a parent in order to switch variations
        guard let parent = self.currentNode.parent else {
            return
        }
        
        let nextVariationIndex = (self.selectedVariationIndices[parent.id] ?? 0) + offset
        
        if parent.variations.indices.contains(nextVariationIndex) {
            self.selectedVariationIndices[parent.id] = nextVariationIndex
            self.currentNode = parent.variations[nextVariationIndex]
        }
    }
    
    /**
     Change the current node to be the next variation from the parent node.
     */
    func updateCurrentNodeToNextVariation() {
        self.updateCurrentNodeToVariationOffsetBy(offset: 1)
    }
    
    /**
     Change the current node to be the previous variation from the parent node.
     */
    func updateCurrentNodeToPreviousVariation() {
        self.updateCurrentNodeToVariationOffsetBy(offset: -1)
    }
    
    /**
     Deletes the current node from the game tree.
     */
    func deleteCurrentNode() {
        guard let parent = self.currentNode.parent else {
            // We shouldn't delete the root node, but we can delete the variations
            self.selectedVariationIndices.removeValue(forKey: self.currentNode.id)
            self.currentNode.variations = []
            self.forceManualRefresh()
            return
        }
        
        // Update the selected variation index appropriately
        if parent.variations.count > 1 {
            // If the parent has multiple variations, update the selected variation index
            self.selectedVariationIndices[parent.id] = max((self.selectedVariationIndices[parent.id] ?? 0) - 1, 0)
        } else {
            // Otherwise, remove the selected variation index
            self.selectedVariationIndices.removeValue(forKey: parent.id)
        }
        
        // Remove the node from the variations
        parent.variations.removeAll { $0 == self.currentNode }
        
        // Change the current node to be the parent
        self.currentNode = parent
    }
    
    // Game management
    
    /**
     Delete a game by its ID.
     
     - Parameters:
        - gameId: The ID of the game to delete.
     */
    func deleteGameById(gameId: Int) {
        // There must always be at least one game
        if self.document.games.count <= 1 {
            return
        }
        
        // Find the index of the game
        let gameIndex: Int? = {
            for (i, game) in self.document.games.enumerated() {
                if game.id == gameId {
                    return i
                }
            }
            return nil
        }()
        guard let gameIndex = gameIndex else {
            return
        }
        
        let newCurrentGameIndex = self.currentGameIndex > gameIndex ? self.currentGameIndex - 1 : self.currentGameIndex
        self.currentGameNodes.removeValue(forKey: gameId)
        self.document.games.remove(at: gameIndex)
        self.currentGameIndex = newCurrentGameIndex
    }
    
    /**
     Delete the current game.
     */
    func deleteCurrentGame() {
        self.deleteGameById(gameId: self.currentGame.id)
    }
    
    /**
     Create a new game.
     */
    func createNewGame() {
        let game = PGNGame()
        game.root.setChessboardForNode(board: Chessboard.initInStartingPosition())
        self.document.games.append(game)
        self.currentGameIndex = self.document.games.indices.count - 1
        
        /*
         guard let undoManager = undoManager else {
             return
         }
         
         undoManager.registerUndo(withTarget: self, handler: { document in
             print("Deleting the newly created game...")
             // Don't delete the game if it has moves
             if game.root.variations.count > 0 {
                 return
             }
             document.deleteGameById(gameId: game.id)
         })
         */
    }
}
