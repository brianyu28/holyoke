//
//  PGNGameListener.swift
//  Holyoke
//
//  Created by Brian Yu on 6/15/22.
//

import Foundation
import Antlr4

class PGNGameListener : PGNBaseListener {
    
    private var games: [PGNGame]
    private var currentGame: PGNGame
    private var variationStack: [PGNGameNode]
    
    static let possibleAnnotationSymbols = ["!!", "!?", "?!", "??", "!", "?"]
    
    override init() {
        games = []
        currentGame = PGNGame()
        variationStack = []
    }
    
    static func parseGamesFromPGNString(pgn: String) -> [PGNGame] {
        if pgn.isEmpty {
            return [PGNGame()]
        }
        
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
            return [PGNGame()]
        }
    }
    
    func getGames() -> [PGNGame] {
        return games
    }
    
    // When leaving a tag pair, add it to the current game's metadata
    override func exitTag_pair(_ ctx: PGNParser.Tag_pairContext) {
        if let tag_name = ctx.tag_name()?.SYMBOL(), let tag_value = ctx.tag_value()?.STRING() {
            let name = tag_name.getText()
            let value = String(tag_value.getText().dropFirst().dropLast()).replacingOccurrences(of: "\\\"", with: "\"")
            currentGame.metadata.append((field: name, value: value))
        }
    }
    
    override func exitElement(_ ctx: PGNParser.ElementContext) {
        if let san_move = ctx.san_move() {
            var moveText = san_move.getText()
            var annotation = ""
            
            // Only six possible annotation symbols
            for possibleAnnotationSymbol in Self.possibleAnnotationSymbols {
                if moveText.hasSuffix(possibleAnnotationSymbol) {
                    moveText = moveText.replacingOccurrences(of: possibleAnnotationSymbol, with: "")
                    annotation = possibleAnnotationSymbol
                    break
                }
            }
            
            // PGN uses O-O (the letter), FIDE algebraic notation uses 0-0 (the number)
            if moveText == "O-O" {
                moveText = "0-0"
            } else if moveText == "O-O-O" {
                moveText = "0-0-0"
            }
            
            if let node = variationStack.last {
                if let _ = node.move {
                    // Node already has a move, add this element as a child
                    let newNode = node.addNewVariation()
                    newNode.move = moveText
                    newNode.annotations = annotation
                    variationStack.removeLast()
                    variationStack.append(newNode)
                } else {
                    // Node doesn't have a move, add the move to this node
                    node.move = moveText
                    node.annotations = annotation
                }
            } else {
                // This is the first move of the game
                let firstMoveNode = currentGame.root.addNewVariation()
                firstMoveNode.move = moveText
                firstMoveNode.annotations = annotation
                variationStack = [firstMoveNode]
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
        currentGame.completeSTRMetadata()
        games.append(currentGame)
        currentGame = PGNGame()
        variationStack = []
    }
}
