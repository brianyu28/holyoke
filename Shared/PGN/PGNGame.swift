//
//  PGNGame.swift
//  Holyoke (macOS)
//
//  Created by Brian Yu on 6/22/22.
//

import Foundation

enum PGNGameTermination: String, CaseIterable {
    case whiteWin = "1-0"
    case blackWin = "0-1"
    case draw = "1/2-1/2"
    case asterisk = "*"
}

class PGNGame: Identifiable {
    /**
     Private counter to keep track of unique game IDs.
     */
    static private var inc: Int = 0
    
    /**
     Unique identifier for game.
     */
    let id: Int
    
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
    
    /**
     Initialize a new game.
     Game starts with no metadata, a single root node without a parent, and a termination of `*`.
     */
    init() {
        Self.inc += 1
        self.id = Self.inc
        
        metadata = []
        root = PGNGameNode(parent: nil)
        gameTermination = .asterisk
    }
    
    /**
     The name of the white player, or `"White"` if not present in the metadata.
     */
    var whitePlayerName: String {
        return self.getMetadata(query: "White") ?? "White"
    }
    
    /**
     The name of the black player, or `"Black"` if not present in the metadata.
     */
    var blackPlayerName: String {
        return self.getMetadata(query: "Black") ?? "Black"
    }
    
    /**
     Description for the title of the game. Includes the player names in addition to the date, if present in the metadata.
     */
    var gameTitleDescription: String {
        let date = self.getMetadata(query: "Date")
        let dateString: String = (date == nil || date == "????.??.??") ? "" : " (\(date!))"
        
        return "\(whitePlayerName) – \(blackPlayerName)\(dateString)"
    }
    
    /**
     The starting `Chessboard` for the game.
     For new games, and for most games, this is the initial starting position for the game of chess.
     However, PGN allows for a `"SetUp"` tag where, if its value is `"1"`, then the `"FEN"` tag is used for the starting position.
     */
    var startingPosition: Chessboard {
        if self.getMetadata(query: "SetUp") != "1" {
            return Chessboard.initInStartingPosition()
        }
        guard let fen = self.getMetadata(query: "FEN") else {
            return Chessboard.initInStartingPosition()
        }
        guard let board = Chessboard.initFromFen(fen: fen) else {
            return Chessboard.initInStartingPosition()
        }
        return board
    }
    
    /**
     Get game metadata based on a tag name.
     
     - Parameters:
        - query: The field name to search for in the metadata.
     
     - Returns: The metadata value for the field, or `nil` if the field is not in the metadata.
     */
    func getMetadata(query: String) -> String? {
        for (field: field, value: value) in metadata {
            if field == query {
                return value
            }
        }
        return nil
    }
    
    /**
     Remove a field from the game's metadata.
     
     - Parameters:
        - field: The field name to remove from the metadata.
     */
    func removeMetadata(field: String) {
        self.metadata.removeAll(where: { (f: String, _: String) in f == field })
    }
    
    /**
     Updates the game metadata for a given field.
     
     - Parameters:
        - field: The field name to update in the metadata.
        - value: The value that should be set for the metadata field.
     */
    func setMetadata(field: String, value: String) {
        for i in metadata.indices {
            if metadata[i].field == field {
                metadata[i] = (field: field, value: value)
                return
            }
        }
        
        // Field not found, add it
        metadata.append((field: field, value: value))
    }
    
    /**
     Updates the starting position of the game.
     If the starting position is different from the starting position of chess, this requires `"SetUp"` and `"FEN"` tags.
     
     - Parameters:
        - fen: FEN representation of the starting position.
     */
    func setStartingPosition(fen: String) {
        if fen == Chessboard.startingPositionFEN {
            self.removeMetadata(field: "SetUp")
            self.removeMetadata(field: "FEN")
        } else {
            self.setMetadata(field: "SetUp", value: "1")
            self.setMetadata(field: "FEN", value: fen)
        }
    }
    
    /**
     Ensure that the required STR (Steven Tag Roster) tags are present in the game.
     */
    func completeSTRMetadata() {
        let requiredTags = [
            (field: "Event", value: "???"),
            (field: "Site", value: "???"),
            (field: "Date", value: "????.??.??"),
            (field: "Round", value: "?"),
            (field: "White", value: "White"),
            (field: "Black", value: "Black"),
            (field: "Result", value: "*")
        ]
        for (field: field, value: value) in requiredTags {
            if self.getMetadata(query: field) == nil {
                self.metadata.append((field: field, value: value))
            }
        }
    }
    
    /**
     Computes the PGN text for the game.
     
     - Returns: The PGN string representing the game and all of its variations.
     */
    func generatePGNText() -> String {
        
        self.setMetadata(field: "Result", value: self.gameTermination.rawValue)

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
        
        pgnString += generateVariationPGNs(node: self.root, includingMoveNumber: true) + self.gameTermination.rawValue + "\n"
        return pgnString
    }
}
