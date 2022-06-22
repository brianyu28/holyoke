//
//  BoardSquare.swift
//  Holyoke
//
//  Created by Brian Yu on 6/22/22.
//

import Foundation

/**
 Represents a square on the chessboard, with a rank and file.
 */
struct BoardSquare: CustomStringConvertible, Equatable, Hashable {
    
    /**
     The rank (row) of the square on the chessboard.
     */
    let rank: BoardRank
    
    /**
     The file (column) of the square on the chessboard.
     */
    let file: BoardFile
    
    /**
     Initializes a new board square based on a rank and file.
     
     - Parameters:
        - rank: The square's rank.
        - file: The square's file.
     */
    init(rank: BoardRank, file: BoardFile) {
        self.rank = rank
        self.file = file
    }
    
    /**
     Initializes a new board square based on SAN notation for the square.
     
     - Parameters:
        - san: SAN representation of board square (e.g. "e4")
     
     - Returns: A board square matching the SAN notation, or `nil` of SAN is invalid.
     */
    static func initFromSan(san: String) -> BoardSquare? {
        if san.count != 2 {
            return nil
        }
        guard let file: BoardFile = Chessboard.fileFromSan(string: String(Array(san)[0])) else {
            return nil
        }
        guard let rank: BoardRank = Chessboard.rankFromSan(string: String(Array(san)[1])) else {
            return nil
        }
        return BoardSquare(rank: rank, file: file)
    }
    
    /**
     Checks if two board squares are equal.
     Board squares are considered equal if they have the same rank and file.
     */
    public static func == (lhs: BoardSquare, rhs: BoardSquare) -> Bool {
        return lhs.rank == rhs.rank && lhs.file == rhs.file
    }
    
    /**
     Hashes a board square.
     Board squares are hashed based on their rank and file.
     */
    func hash(into hasher: inout Hasher) {
            hasher.combine(rank)
            hasher.combine(file)
    }
    
    /**
     SAN notation representation of the square's file, or `"?"` if the file is invalid.
     */
    var fileNotation: String { Chessboard.sanFromFile(file: self.file) ?? "?" }

    /**
     SAN notation representation of the square's rank, assumed to be valid.
     */
    var rankNotation: String { Chessboard.sanFromRank(rank: self.rank) }
    
    /**
     SAN notation representation of the square.
     */
    var notation: String { "\(fileNotation)\(rankNotation)" }
    
    /**
     Description of the string using SAN notation.
     Used to conform to `CustomStringConvertible` so that `BoardSquare`s can be printed.
     */
    var description: String { notation }
    
    /**
     Whether the square is a valid square on the board.
     */
    var isValidSquare: Bool { Chessboard.isValidRank(rank: self.rank) && Chessboard.isValidFile(file: self.file) }
}
