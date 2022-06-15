//
//  PGN.swift
//  Holyoke
//
//  Created by Brian Yu on 6/15/22.
//

import Foundation
import Antlr4

enum PGNGameTermination: String {
    case WhiteWin = "1-0"
    case BlackWin = "0-1"
    case Draw = "1/2-1/2"
    case Asterisk = "*"
}

class PGNGame {
    /**
     Game metadata. Standard game metadata includes "Event", "Site", "Date", "Round", "White", "Black", "Result"
     */
    var metadata : [(field: String, value: String)]
    
    /**
     Tree of moves.
     */
    var variations: PGNGameVariations
    
    /**
     Game termination symbol.
     */
    var gameTermination: PGNGameTermination
    
    init() {
        metadata = []
        variations = PGNGameVariations(moveNumber: 1, playerColor: .white)
        gameTermination = .Asterisk
    }
}

class PGNGameVariations {
    let moveNumber : Int
    let playerColor : PlayerColor
    
    var variations: [PGNGameVariation]
    var parentVariation: PGNGameVariation?
    
    init(moveNumber: Int, playerColor: PlayerColor) {
        self.moveNumber = moveNumber
        self.playerColor = playerColor
        variations = []
        parentVariation = nil
    }
    
    func addVariation(variation: PGNGameVariation) {
        variations.append(variation)
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
}

/**
 Represents a node in a tree of moves.
 */
class PGNGameVariation {
    var moveText : String
    var numericAnnotation : String
    var braceComment : String
    var restOfLineComment : String
    var annotations : String
    var variationGroup: PGNGameVariations
    
    // Subsequent moves that follow from this move
    var variations : PGNGameVariations
    
    init(variationGroup: PGNGameVariations) {
        moveText = ""
        numericAnnotation = ""
        braceComment = ""
        restOfLineComment = ""
        annotations = ""
        variations = PGNGameVariations(moveNumber: variationGroup.nextMoveNumber, playerColor: variationGroup.playerColor.nextColor)
        self.variationGroup = variationGroup
        variations.parentVariation = self
    }
    
    func currentMoveDescription() -> String {
        return "\(variationGroup.moveNumber)\(variationGroup.playerColor == .white ? "." : "...") \(moveText) \(annotations != "" ? "{\(annotations)}" : "")"
    }
}


class PGNGameListener : PGNBaseListener {
    
    private var games: [PGNGame]
    private var currentGame: PGNGame
    private var variationStack: [PGNGameVariation?]
    
    override init() {
        games = []
        currentGame = PGNGame()
        variationStack = []
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
            
            let last = variationStack.last
            if last != nil, let variation = last! {
                // Variation stack already has a move, add as a next move to the existing move
                let newVariation = PGNGameVariation(variationGroup: variation.variations)
                newVariation.moveText = moveText
                variation.variations.addVariation(variation: newVariation)
                variationStack.removeLast()
                variationStack.append(newVariation)
            } else {
                // Variation stack is empty, this is the first move
                let newVariation = PGNGameVariation(variationGroup: currentGame.variations)
                newVariation.moveText = moveText
                currentGame.variations.addVariation(variation: newVariation)
                variationStack.append(newVariation)
            }
        } else if let braceComment = ctx.BRACE_COMMENT() {
            let last = variationStack.last
            if last != nil, let variation = last! {
                variation.annotations = String(braceComment.getText().dropFirst().dropLast()).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }
    
    override func enterRecursive_variation(_ ctx: PGNParser.Recursive_variationContext) {
        let last = variationStack.last
        if last != nil, let variation = last! {
            let parentVariation = variation.variationGroup.parentVariation
            variationStack.append(parentVariation)
        } else {
            variationStack.append(nil)
        }
    }
    
    override func exitRecursive_variation(_ ctx: PGNParser.Recursive_variationContext) {
        if let _ = variationStack.last {
            variationStack.removeLast()
        }
    }
    
    override func exitGame_termination(_ ctx: PGNParser.Game_terminationContext) {
        if ctx.WHITE_WINS() != nil {
            currentGame.gameTermination = .WhiteWin
        } else if ctx.BLACK_WINS() != nil {
            currentGame.gameTermination = .BlackWin
        } else if ctx.DRAWN_GAME() != nil {
            currentGame.gameTermination = .Draw
        } else {
            currentGame.gameTermination = .Asterisk
        }
    }
    
    override func exitPgn_game(_ ctx: PGNParser.Pgn_gameContext) {
        
        func printVariation(variation: PGNGameVariation?, indent: Int) {
            guard let variation = variation else {
                return
            }
            let spaces = String(repeating: " ", count: indent)
            print(spaces + variation.currentMoveDescription() )
            for subvariation in variation.variations.variations {
                printVariation(variation: subvariation, indent: indent + 1)
            }
            
        }
        printVariation(variation: currentGame.variations.variations[0], indent: 0)
        games.append(currentGame)
        currentGame = PGNGame()
    }
}
