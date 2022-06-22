//
//  PieceAsset.swift
//  Holyoke
//
//  Created by Brian Yu on 6/22/22.
//

import Foundation

/**
 Extension to `PlayerColor` enum that allows getting a color's full name as a string.
 */
extension PlayerColor {
    /**
     Full name for color.
     */
    var fullName: String {
        switch self {
        case .white:
            return "White"
        case .black:
            return "Black"
        }
    }
}

/**
 Extension to `PieceType` enum that allows getting the piece type's full name as a string.
 */
extension PieceType {
    /**
     Full name for piece type.
     */
    var fullName: String {
        switch self {
        case .king:
            return "King"
        case .queen:
            return "Queen"
        case .rook:
            return "Rook"
        case .bishop:
            return "Bishop"
        case .knight:
            return "Knight"
        case .pawn:
            return "Pawn"
        }
    }
}

/**
 Extension to Piece `struct` that handles determining what image assets to use for piece.
 */
extension Piece {
    /**
     Image asset name to use for the piece.
     */
    var assetName: String {
        return "ChessPiece_\(color.fullName)_\(type.fullName)"
    }
}
