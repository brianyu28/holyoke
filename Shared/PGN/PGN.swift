//
//  PGN.swift
//  Holyoke
//
//  Created by Brian Yu on 6/15/22.
//

import Foundation
import Antlr4

class PGNGame {
    /**
     Game metadata. Standard game metadata includes "Event", "Site", "Date", "Round", "White", "Black", "Result"
     */
    var metadata : [(field: String, value: String)]
    
    /**
     Tree of moves.
     */
    var root: PGNGameNode
    
    /**
     Game termination symbol.
     */
    var gameTermination: PGNGameTermination
    
    init() {
        metadata = []
        root = PGNGameNode(parent: nil)
        gameTermination = .asterisk
    }
}

/**
 Represents a node in a game tree.
 */
class PGNGameNode {
    let moveNumber: Int
    let playerColor: PlayerColor
    
    var variations: [PGNGameNode]
    var parent: PGNGameNode?
    
    var move: String?
    var numericAnnotation : String
    var braceComment : String
    var restOfLineComment : String
    var annotations : String
    
    init(parent: PGNGameNode?) {
        self.moveNumber = parent?.nextMoveNumber ?? 0
        self.playerColor = parent?.playerColor.nextColor ?? .black
        self.variations = []
        self.parent = parent
        
        self.move = nil
        self.numericAnnotation = ""
        self.braceComment = ""
        self.restOfLineComment = ""
        self.annotations = ""
    }
    
    // If current player is White, next move is the same move number
    var nextMoveNumber: Int {
        switch playerColor {
        case .white:
            return moveNumber
        case .black:
            return moveNumber + 1
        }
    }
    
    var currentMoveDescription: String {
        return "\(moveNumber)\(playerColor == .white ? "." : "...") \(move ?? "--") \(braceComment != "" ? "{\(braceComment)}" : "")"
    }
    
    /**
     Add an existing node as a child of the node.
     */
    func addVariation(variation: PGNGameNode) {
        self.variations.append(variation)
    }
    
    /**
     Create and return a new child node.
     */
    func addNewVariation() -> PGNGameNode {
        let variation = PGNGameNode(parent: self)
        self.variations.append(variation)
        return variation
    }
}

enum PGNGameTermination: String {
    case whiteWin = "1-0"
    case blackWin = "0-1"
    case draw = "1/2-1/2"
    case asterisk = "*"
}

class PGNGameListener : PGNBaseListener {
    
    private var games: [PGNGame]
    private var currentGame: PGNGame
    private var variationStack: [PGNGameNode]
    
    override init() {
        games = []
        currentGame = PGNGame()
        let firstMoveNode = currentGame.root.addNewVariation()
        variationStack = [firstMoveNode]
    }
    
    static func parseGamesFromPGNString(pgn: String) -> [PGNGame] {
        do {
            let inputStream = ANTLRInputStream(pgn)
            let lexer = PGNLexer(inputStream)
            let tokenStream = CommonTokenStream(lexer)
            let parser = try PGNParser(tokenStream)
            let expressionContext = try parser.pgn_database()
            let listener = PGNGameListener()
            try ParseTreeWalker().walk(listener, expressionContext)
            return listener.getGames()
        } catch {
            return []
        }
    }
    
    func getGames() -> [PGNGame] {
        return games
    }
    
    // When leaving a tag pair, add it to the current game's metadata
    override func exitTag_pair(_ ctx: PGNParser.Tag_pairContext) {
        if let tag_name = ctx.tag_name()?.SYMBOL(), let tag_value = ctx.tag_value()?.STRING() {
            let name = tag_name.getText()
            let value = String(tag_value.getText().dropFirst().dropLast())
            currentGame.metadata.append((field: name, value: value))
        }
    }
    
    override func exitElement(_ ctx: PGNParser.ElementContext) {
        if let san_move = ctx.san_move() {
            let moveText = san_move.getText() // TODO: Separate move from move annotation.
            
            if let node = variationStack.last {
                if let _ = node.move {
                    // Node already has a move, add this element as a child
                    let newNode = node.addNewVariation()
                    newNode.move = moveText
                    variationStack.removeLast()
                    variationStack.append(newNode)
                } else {
                    // Node doesn't have a move, add the move to this node
                    node.move = moveText
                }
            }
        } else if let braceComment = ctx.BRACE_COMMENT() {
            if let node = variationStack.last {
                node.braceComment = String(braceComment.getText().dropFirst().dropLast()).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }
    
    override func enterRecursive_variation(_ ctx: PGNParser.Recursive_variationContext) {
        if let node = variationStack.last {
            if let parent = node.parent {
                variationStack.append(parent.addNewVariation())
            }
        }
    }
    
    override func exitRecursive_variation(_ ctx: PGNParser.Recursive_variationContext) {
        if let _ = variationStack.last {
            variationStack.removeLast()
        }
    }
    
    override func exitGame_termination(_ ctx: PGNParser.Game_terminationContext) {
        if ctx.WHITE_WINS() != nil {
            currentGame.gameTermination = .whiteWin
        } else if ctx.BLACK_WINS() != nil {
            currentGame.gameTermination = .blackWin
        } else if ctx.DRAWN_GAME() != nil {
            currentGame.gameTermination = .draw
        } else {
            currentGame.gameTermination = .asterisk
        }
    }
    
    override func exitPgn_game(_ ctx: PGNParser.Pgn_gameContext) {
        
        func printNode(node: PGNGameNode, indent: Int) {
            let spaces = String(repeating: " ", count: indent)
            print(spaces + node.currentMoveDescription )
            for variation in node.variations {
                printNode(node: variation, indent: indent + 1)
            }
            
        }
        printNode(node: currentGame.root, indent: 0)
        games.append(currentGame)
        currentGame = PGNGame()
    }
}
