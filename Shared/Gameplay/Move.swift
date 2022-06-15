//
//  Move.swift
//  Holyoke (iOS)
//
//  Created by Brian Yu on 6/11/22.
//

import Foundation

/**
 Represents color of player and color of piece.
 */
enum PlayerColor {
    case white
    case black
}

/**
 Represents a chess piece.
 */
enum PieceType {
    case king
    case queen
    case rook
    case bishop
    case knight
    case pawn
}

struct Piece : CustomStringConvertible {
    let color : PlayerColor
    let type : PieceType
    
    // Return piece description in FEN notation
    var description : String {
        let symbol : String = {
            switch type {
            case .king:
                return "K"
            case .queen:
                return "Q"
            case .rook:
                return "R"
            case .bishop:
                return "B"
            case .knight:
                return "N"
            case .pawn:
                return "P"
            }
        }()
        return color == .white ? symbol : symbol.lowercased()
    }
}

/**
 Represents a chess move as (rank, file), each in [0, 7].
 */
typealias BoardSquare = (Int, Int)

/**
 Represents a chess move.
 */
struct Move {
    let piece : Piece
    let newSquare : BoardSquare
    let isCapture : Bool
    
    // Additional metadata for "special" moves.
    let isCastleShort : Bool
    let isCastleLong : Bool
    let promotion : PieceType?
}
