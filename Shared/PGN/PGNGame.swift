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
    // Incremenets to keep track of unique game IDs
    static private var inc: Int = 0
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
    
    init() {
        Self.inc += 1
        self.id = Self.inc
        
        metadata = []
        root = PGNGameNode(parent: nil)
        gameTermination = .asterisk
    }
    
    var whitePlayerName: String {
        return self.getMetadata(query: "White") ?? "White"
    }
    
    var blackPlayerName: String {
        return self.getMetadata(query: "Black") ?? "Black"
    }
    
    var gameTitleDescription: String {
        let date = self.getMetadata(query: "Date")
        let dateString: String = (date == nil || date == "????.??.??") ? "" : " (\(date!))"
        
        return "\(whitePlayerName) – \(blackPlayerName)\(dateString)"
    }
    
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
    
    func getMetadata(query: String) -> String? {
        for (field: field, value: value) in metadata {
            if field == query {
                return value
            }
        }
        return nil
    }
    
    func removeMetadata(field: String) {
        self.metadata.removeAll(where: { (f: String, _: String) in f == field })
    }
    
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
    
    func setStartingPosition(fen: String) {
        if fen == Chessboard.startingPositionFEN {
            self.removeMetadata(field: "SetUp")
            self.removeMetadata(field: "FEN")
        } else {
            self.setMetadata(field: "SetUp", value: "1")
            self.setMetadata(field: "FEN", value: fen)
        }
    }
    
    // Ensure that the required STR (Steven Tag Roster) tags are present
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
