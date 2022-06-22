//
//  PieceType.swift
//  Holyoke
//
//  Created by Brian Yu on 6/22/22.
//

import Foundation

/**
 Represents a type of chess piece, independent of color.
 */
enum PieceType {
    case king
    case queen
    case rook
    case bishop
    case knight
    case pawn
    
    /**
     Single-letter capitalized description of piece type.
     Used in SAN notation for any moves involving this type of piece.
     */
    var description: String {
        switch self {
        case .king: return "K"
        case .queen: return "Q"
        case .rook: return "R"
        case .bishop: return "B"
        case .knight: return "N"
        case .pawn: return "P"
        }
    }
    
    /**
     Returns a piece type from a single-letter capitalized description of piece.
     
     - Parameters:
        - description: The single-character capitalized piece description.
     
     - Returns: A piece type matching the description, or `nil` if no piece type matches.
     */
    static func fromDescription(description: String) -> PieceType? {
        switch description {
        case "K": return .king
        case "Q": return .queen
        case "R": return .rook
        case "B": return .bishop
        case "N": return .knight
        case "P": return .pawn
        default: return nil
        }
    }
}
