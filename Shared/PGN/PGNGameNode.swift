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
    /**
     Private counter to keep track of game node IDs.
     */
    static private var inc: Int = 0
    
    /**
     Unique identifier for game node.
     */
    let id: Int
    
    /**
     Move number represented by the current node.
     */
    var moveNumber: Int
    
    /**
     Player that just made a move in the current position.
     At the start of a new game, this is Black, since White gets the first move.
     */
    var playerColor: PlayerColor
    
    /**
     Array of variations that follow the current node.
     */
    var variations: [PGNGameNode]
    
    /**
     The game node that preceded this node in the game tree.
     `nil` if the game node has no parent (the root node).
     */
    var parent: PGNGameNode?
    
    /**
     String representing the SAN notation for the move.
     */
    var move: String?
    
    /**
     Numeric annotation on the move.
     Currently unused.
     */
    var numericAnnotation : String
    
    /**
     Comment enclosed in `{` and `}` following the move.
     Used for most comments about the move.
     */
    var braceComment : String
    
    /**
     End-of-line comment text.
     Currently unused.
     */
    var restOfLineComment : String
    
    /**
     Annotations (`!`, `?`, etc.) for the current move.
     */
    var annotations : String
    
    /**
     Whether the move made is check.
     */
    var isCheck: Bool
    
    /**
     Whether the move made is checkmate.
     */
    var isCheckmate: Bool
    
    /**
     Chessboard for the current node, so that we can return to it more easily.
     */
    var chessboard: Chessboard?
    
    /**
     Which of the node's variations is "selected"; that is, should be chosen when the user progresses to the next move.
     */
    // TODO: Move this out of the PGNGameNode class into separate app state?
    var selectedVariationIndex: Int?
    
    /**
     Initialize a new game node.
     */
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
        
        self.chessboard = nil
        self.selectedVariationIndex = nil
    }
    
    /**
     Compare two game nodes for equality.
     */
    public static func == (lhs: PGNGameNode, rhs: PGNGameNode) -> Bool {
        return lhs.id == rhs.id
    }
    
    /**
     The full move number for the next move. Increments only after a Black move.
     */
    // TODO: Handle cases where the first move in the starting position isn't move 1.
    var nextMoveNumber: Int {
        // The first move of the game is always move 1, regardless of the color to move first
        if self.parent == nil {
            return 1
        }
        switch playerColor {
        case .white: return moveNumber
        case .black: return moveNumber + 1
        }
    }
    
    /**
     Add an existing node as a child of the node.
     
     - Parameters:
        - variation: The variation to add to the current game node.
     */
    func addVariation(variation: PGNGameNode) {
        self.variations.append(variation)
    }
    
    /**
     Set a particular variation as the selected variation for the game node.
     
     - Parameters:
        - variation: The variation to set as the selected variation.
     */
    func setSelectedVariation(variation: PGNGameNode) {
        self.selectedVariationIndex = nil
        for (i, possibleVariation) in self.variations.enumerated() {
            if possibleVariation.move == variation.move {
                self.selectedVariationIndex = i
                break
            }
        }
    }
    
    /**
     Create and return a new child node as a variation on the current node.
     
     - Returns: The newly created game node.
     */
    func addNewVariation() -> PGNGameNode {
        let variation = PGNGameNode(parent: self)
        self.variations.append(variation)
        return variation
    }
    
    /**
     Return the PGN move notation for the current move.
     
     - Parameters:
        - withMoveNumber: Whether the move number be included in the output.
        - withComments: Whether brace comments should be included in the output.
     */
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
    
    /**
     Return the sequence of PGN moves from the root until the current node.
     
     - Returns: PGN string.
     */
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
