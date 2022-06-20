//
//  PGN.swift
//  Holyoke
//
//  Created by Brian Yu on 6/15/22.
//

import Foundation
import Antlr4


// Location for where a PGNGameNode should be placed
struct GameLayoutPoint: Hashable, Equatable {
    let row: Int
    let col: Int
    
    public static func == (lhs: GameLayoutPoint, rhs: GameLayoutPoint) -> Bool {
        return lhs.row == rhs.row && lhs.col == rhs.col
    }
}

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
    
    func generateNodeLayout() -> (layout: [[PGNGameNode?]], locations: [Int: Int]) {
        
        // 2D array of (row, col) for where PGNGameNodes are laid out
        var layout: [[PGNGameNode?]] = []
        
        // Mapping from PGNGameNode ID -> row index in the final game layout
        var locations: [Int: Int] = [:]
        
        var avoid: Set<GameLayoutPoint> = []
        
        // Add node to layout with a minimum row, return its actual row
        func addNode(node: PGNGameNode, startingAtRowIndex startRow: Int) -> Int {
            let col: Int = node.layoutColumn
            var row: Int = startRow
            
            while (true) {
                // Ensure that locations has enough rows
                while layout.count <= row {
                    layout.append([])
                }
                
                while layout[row].count <= col {
                    layout[row].append(nil)
                }
                
                if layout[row][col] == nil && !avoid.contains(GameLayoutPoint(row: row, col: col)) {
                    // There's space at the desired row
                    layout[row][col] = node
                    locations[node.id] = row
                    
                    // Avoid placing nodes between the parent and this node
                    if let parentRow = node.parent != nil ? locations[node.parent!.id] : nil {
                        if parentRow <= row {
                            for r in parentRow...row {
                                avoid.insert(GameLayoutPoint(row: r, col: col - 1))
                            }
                        }
                    }
                    
                    return row
                } else {
                    row += 1
                }
            }
        }
        
        func addVariation(node startNode: PGNGameNode, startingAtRowIndex startRow: Int) -> Int {
            
            // Keep track of nodes, so we can add variations later
            var nodes: [PGNGameNode] = []
            var currentRowIndex = startRow
            
            // What's the highest row index that was used
            var maxRowIndex = startRow
            
            // Loop through all of the moves, adding each where it fits
            var node: PGNGameNode? = startNode
            while (true) {
                guard let n = node else {
                    break
                }
                nodes.append(n)
                currentRowIndex = addNode(node: n, startingAtRowIndex: currentRowIndex)
                
                if n.variations.count == 0 {
                    break
                }
                node = n.variations[0]
            }
            
            // Go through and add variations
            for node in nodes.reversed() {
                var rowIndex: Int = locations[node.id] ?? 0
                for variation in node.variations.dropFirst() {
                    rowIndex = addVariation(node: variation, startingAtRowIndex: rowIndex + 1)
                    if rowIndex > maxRowIndex {
                        maxRowIndex = rowIndex
                    }
                }
            }
            
            return maxRowIndex
        }
        
        let _ = addVariation(node: self.root, startingAtRowIndex: 0)
        
        return (layout: layout, locations: locations)
    }
    
    func generatePGNText() -> String {
        var pgnString = ""
        for tag in metadata {
            pgnString += "[\(tag.field) \"\(tag.value.replacingOccurrences(of: "\"", with: "\\\""))\"]\n"
        }
        pgnString += "\n"
        

        func generateVariationPGNs(node: PGNGameNode?, includingMoveNumber: Bool) -> String {
            
            var currentNode: PGNGameNode? = node
            
            var requireNumber: Bool = includingMoveNumber
            var pgnString: String = ""
            
            while (true) {
                guard let n = currentNode else {
                    break
                }
                
                if n.variations.count >= 1 {
                    
                    let showMoveNumber = n.variations[0].playerColor == .white || requireNumber
                    requireNumber = false
                    
                    pgnString += n.variations[0].pgnNotation(withMoveNumber: showMoveNumber, withComments: true)
                    if !n.variations[0].braceComment.isEmpty {
                        requireNumber = true
                    }
                
                    if n.variations.count > 1 {
                        for variation in n.variations.dropFirst() {
                            pgnString += "( "
                            pgnString += variation.pgnNotation(withMoveNumber: true, withComments: true)
                            pgnString += generateVariationPGNs(node: variation, includingMoveNumber: !variation.braceComment.isEmpty)
                            pgnString += ") "
                        }
                        
                        requireNumber = true
                    }
                    currentNode = n.variations[0]
                } else {
                    currentNode = nil
                }

            }
            
            return pgnString
        }
        
        pgnString += generateVariationPGNs(node: self.root, includingMoveNumber: false) + self.gameTermination.rawValue + "\n"
        return pgnString
    }
}

/**
 Represents a node in a game tree.
 */
class PGNGameNode: Identifiable, Equatable {
    // Incremenets to keep track of unique game node IDs
    static private var inc: Int = 0

    let id: Int
    let moveNumber: Int
    let playerColor: PlayerColor
    
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
    
    // In a layout of all nodes, what column should this node be in
    // This is determined by the node's move number and color
    var layoutColumn: Int {
        switch playerColor {
        case .white:
            return moveNumber * 2 - 1
        case .black:
            return moveNumber * 2
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
    
    static let possibleAnnotationSymbols = ["!!", "!?", "?!", "??", "!", "?"]
    
    override init() {
        games = []
        currentGame = PGNGame()
        let firstMoveNode = currentGame.root.addNewVariation()
        variationStack = [firstMoveNode]
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
        games.append(currentGame)
        currentGame = PGNGame()
    }
}
