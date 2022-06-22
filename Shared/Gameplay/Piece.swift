//
//  Piece.swift
//  Holyoke
//
//  Created by Brian Yu on 6/22/22.
//

import Foundation

/**
 Represents a piece on the chessboard, based on the piece's color and piece type.
 */
struct Piece : CustomStringConvertible, Equatable {
    
    /**
     The color of the piece.
     */
    let color: PlayerColor
    
    /**
     The type of piece.
     */
    let type: PieceType
    
    /**
     FEN notation single-character description of the piece.
     Capital letter indicates a White piece, lowercase letter indicates a Black piece.
     */
    var description: String {
        return color == .white ? type.description : type.description.lowercased()
    }

    /**
     Returns a piece based on a FEN notation single-character description.
     
     - Parameters:
        - description: Single-character FEN notation for piece.
     
     - Returns: A piece matching the description, or `nil` if no piece matches.
     */
    static func fromDescription(description: String) -> Piece? {
        guard let pieceType = PieceType.fromDescription(description: description.uppercased()) else {
            return nil
        }
        return Piece(color: description.uppercased() == description ? .white : .black, type: pieceType)
    }
    
    /**
     Checks whether two piece `struct`s represent the same piece.
     Two pieces are considered the same if they share the same color and type.
     */
    public static func == (lhs: Piece, rhs: Piece) -> Bool {
        return lhs.color == rhs.color && lhs.type == rhs.type
    }
}
