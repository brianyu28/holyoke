//
//  PGNGameNode.swift
//  Holyoke (macOS)
//
//  Created by Brian Yu on 6/22/22.
//

import Foundation

/**
 Represents a node in a game tree.
 */
class PGNGameNode: Identifiable, Equatable {
    // Incremenets to keep track of unique game node IDs
    static private var inc: Int = 0
    let id: Int
    
    let moveNumber: Int
    
    // Player that just moved in the current position
    // At the start of a new game, this is technically Black, since White gets the first move
    var playerColor: PlayerColor
    
    var variations: [PGNGameNode]
    var parent: PGNGameNode?
    
    var move: String?
    var numericAnnotation : String
    var braceComment : String
    var restOfLineComment : String
    var annotations : String
    
    var isCheck: Bool
    var isCheckmate: Bool
    
    // Which of the variations is "selected"; that is, should be chosen when we go to the next move
    var selectedVariationIndex: Int?
    
    // Chessboard for current node, so that we can return to nodes more easily
    var chessboard: Chessboard?
    
    init(parent: PGNGameNode?) {
        Self.inc += 1
        self.id = Self.inc
        
        self.moveNumber = parent?.nextMoveNumber ?? 0
        self.playerColor = parent?.playerColor.nextColor ?? .black
        self.variations = []
        self.parent = parent
        
        self.move = nil
        self.numericAnnotation = ""
        self.braceComment = ""
        self.restOfLineComment = ""
        self.annotations = ""
        
        self.isCheck = false
        self.isCheckmate = false
        
        self.selectedVariationIndex = nil
        
        self.chessboard = nil
    }
    
    public static func == (lhs: PGNGameNode, rhs: PGNGameNode) -> Bool {
        return lhs.id == rhs.id
        
    }
    
    // If current player is White, next move is the same move number
    var nextMoveNumber: Int {
        // The first move of the game is always move 1, regardless of the color to move first
        if self.parent == nil {
            return 1
        }
        switch playerColor {
        case .white:
            return moveNumber
        case .black:
            return moveNumber + 1
        }
    }
    
    var mainlineLength: Int {
        if self.variations.count > 0 {
            return 1 + self.variations[0].mainlineLength
        } else {
            return 1
        }
    }
    
    /**
     Add an existing node as a child of the node.
     */
    func addVariation(variation: PGNGameNode) {
        self.variations.append(variation)
    }
    
    func setSelectedVariation(variation: PGNGameNode) {
        self.selectedVariationIndex = nil
        for (i, possibleVariation) in self.variations.enumerated() {
            if possibleVariation.move == variation.move {
                self.selectedVariationIndex = i
                break
            }
        }
    }
    
    // Sets which player is to move in the current position, propogates to subsequent nodes
    func setPlayerToMove(playerToMove: PlayerColor) {
        let currentPlayerColor = self.playerColor
        
        // playerColor should be the opposite of playerToMove,
        // since playerColor is who just moved in this node, and playerToMove is whose turn it is next
        // If they're the same, then we need to flip them
        if currentPlayerColor == playerToMove {
            self.playerColor = playerToMove.nextColor
            for variation in self.variations {
                variation.setPlayerToMove(playerToMove: playerToMove.nextColor)
            }
            
        }
    }
    
    /**
     Create and return a new child node.
     */
    func addNewVariation() -> PGNGameNode {
        let variation = PGNGameNode(parent: self)
        self.variations.append(variation)
        return variation
    }
    
    func pgnNotation(withMoveNumber: Bool, withComments: Bool) -> String {
        var pgn = ""
        if withMoveNumber {
            if playerColor == .white {
                pgn += "\(moveNumber). "
            } else {
                pgn += "\(moveNumber)... "
            }
        }
        
        pgn += (move == "0-0" ? "O-O" : move == "0-0-0" ? "O-O-O" : move) ?? "?"
        if self.isCheckmate {
            pgn += "#"
        } else if self.isCheck {
            pgn += "+"
        }
        pgn += annotations
        pgn += " "
        
        if withComments && !braceComment.isEmpty {
            pgn += "{ \(braceComment.replacingOccurrences(of: "{", with: "(").replacingOccurrences(of: "}", with: ")")) } "
        }
        return pgn
    }
    
    func moveSequenceUntilCurrentNode() -> String {
        if self.moveNumber == 0 {
            return ""
        }
        let currentMove = self.pgnNotation(withMoveNumber: self.playerColor == .white, withComments: false)
        if let parent = self.parent {
            return parent.moveSequenceUntilCurrentNode() + " " + currentMove
        } else {
            return currentMove
        }
    }
}
