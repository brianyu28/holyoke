//
//  Move.swift
//  Holyoke (iOS)
//
//  Created by Brian Yu on 6/11/22.
//

import Foundation

/**
 Represents a chess move.
 */
struct Move: Identifiable, Equatable {
    let piece: Piece
    let currentSquare: BoardSquare
    let newSquare: BoardSquare
    let isCapture: Bool
    
    // Additional metadata for "special" moves.
    let isCastleShort: Bool
    let isCastleLong: Bool
    let isEnPassant: Bool
    let promotion: PieceType?
    
    var id: String {
        return "\(piece.description)\(currentSquare.notation)\(newSquare.notation)"
    }
    
    public static func == (lhs: Move, rhs: Move) -> Bool {
        return (lhs.piece == rhs.piece && lhs.currentSquare == rhs.currentSquare && lhs.newSquare == rhs.newSquare &&
                lhs.isCastleShort == rhs.isCastleShort && lhs.isCastleLong == rhs.isCastleLong &&
                lhs.isEnPassant == rhs.isEnPassant && lhs.promotion == rhs.promotion)
        
    }
    
    // Initializer for normal moves
    init(piece: Piece, currentSquare: BoardSquare, newSquare: BoardSquare, isCapture: Bool) {
        self.piece = piece
        self.currentSquare = currentSquare
        self.newSquare = newSquare
        self.isCapture = isCapture
        
        self.isCastleShort = false
        self.isCastleLong = false
        self.isEnPassant = false
        self.promotion = nil
    }
    
    init(withPieceCastlingShort piece: Piece) {
        if piece.type != .king {
            fatalError("Attempt to castle short with a non-king piece.")
        }
        self.piece = piece
        self.currentSquare = BoardSquare(rank: piece.color == .white ? 7 : 0, file: 4)
        self.newSquare = BoardSquare(rank: piece.color == .white ? 7 : 0, file: 6)
        self.isCapture = false
        
        self.isCastleShort = true
        self.isCastleLong = false
        self.isEnPassant = false
        self.promotion = nil
    }
    
    init(withPieceCastlingLong piece: Piece) {
        if piece.type != .king {
            fatalError("Attempt to castle short with a non-king piece.")
        }
        self.piece = piece
        self.currentSquare = BoardSquare(rank: piece.color == .white ? 7 : 0, file: 4)
        self.newSquare = BoardSquare(rank: piece.color == .white ? 7 : 0, file: 2)
        self.isCapture = false
        
        self.isCastleShort = false
        self.isCastleLong = true
        self.isEnPassant = false
        self.promotion = nil
    }
    
    init(withEnPassantByPawn piece: Piece, currentSquare: BoardSquare, newSquare: BoardSquare) {
        if piece.type != .pawn {
            fatalError("Attempt to en passant with a non-pawn piece.")
        }
        self.piece = piece
        self.currentSquare = currentSquare
        self.newSquare = newSquare
        self.isCapture = true
        
        self.isCastleShort = false
        self.isCastleLong = false
        self.isEnPassant = true
        self.promotion = nil
    }
    
    init(withPawnPromoting piece: Piece, toPiece newPiece: PieceType, currentSquare: BoardSquare, newSquare: BoardSquare, isCapture: Bool) {
        if piece.type != .pawn {
            fatalError("Attempted to promote a non-pawn piece.")
        }
        self.piece = piece
        self.currentSquare = currentSquare
        self.newSquare = newSquare
        self.isCapture = isCapture
        
        self.isCastleShort = false
        self.isCastleLong = false
        self.isEnPassant = false
        self.promotion = newPiece
    }
}
