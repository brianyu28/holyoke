//
//  BoardRank.swift
//  Holyoke
//
//  Created by Brian Yu on 6/22/22.
//

import Foundation

/**
 Represents the rank of a square of a chessboard as a value in `[0, 7]`.
 0 represents the 8th rank, 7 represents the 1st rank.
 */
typealias BoardRank = Int

extension Chessboard {
    // Constants representing numbered ranks
    static let firstRank: BoardRank = 7
    static let secondRank: BoardRank = 6
    static let thirdRank: BoardRank = 5
    static let fourthRank: BoardRank = 4
    static let fifthRank: BoardRank = 3
    static let sixthRank: BoardRank = 2
    static let seventhRank: BoardRank = 1
    static let eighthRank: BoardRank = 0
    
    // Constants representing ranks with special meanings
    static let whiteCastlingRank: BoardRank = Chessboard.firstRank
    static let blackCastlingRank: BoardRank = Chessboard.eighthRank
    static let whitePromotionRank: BoardRank = Chessboard.eighthRank
    static let blackPromotionRank: BoardRank = Chessboard.firstRank
    static let whitePawnStartRank: BoardRank = Chessboard.secondRank
    static let blackPawnStartRank: BoardRank = Chessboard.seventhRank
    static let whiteEnPassantTargetRank: BoardRank = Chessboard.sixthRank
    static let blackEnPassantTargetRank: BoardRank = Chessboard.thirdRank
    
    /**
     Range of all possible ranks.
     */
    static let ranks: ClosedRange<Int> = 0...7

    /**
     Computes whether the rank is a valid rank on the chessboard.
     
     - Parameters:
        - rank: A rank on the board.
     
     - Returns: `true` if the rank is a valid rank on the board, `false` otherwise.
     */
    static func isValidRank(rank: BoardRank) -> Bool { Self.ranks.contains(rank) }
    
    /**
     Returns a board rank based on the SAN algebraic notation representation of the rank.
     
     - Parameters:
        - string: Single-character string representing the board's rank in SAN.
     
     - Returns: The board rank described by the string, or `nil` if the string is invalid.
     */
    static func rankFromSan(string: String) -> BoardRank? {
        guard let sanRankNumber: Int = Int(string) else {
            return nil
        }
        let rank: BoardRank = 8 - sanRankNumber
        return Chessboard.isValidRank(rank: rank) ? rank : nil
    }
    
    /**
     Given a rank, returns its SAN representation as a string.
     For example, for a rank of `0`, this function would return `7`.
     
     - Parameters:
        - rank: A rank on the board, assumed to be valid.
     
     - Returns: The string ("a" through "h") representing the file, or `nil` if the file is invalid.
     */
    static func sanFromRank(rank: BoardRank) -> String { String(8 - rank) }
    
    /**
     Returns the rank that a player castles on.
     
     - Parameters:
        - color: The color of the player that is castling.
     
     - Returns: The rank of the player's king and rook when castling.
     */
    static func castlingRankFor(color: PlayerColor) -> BoardRank {
        color == .white ? Chessboard.whiteCastlingRank : Chessboard.blackCastlingRank
    }
}
