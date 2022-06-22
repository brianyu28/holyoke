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
    
    /**
     The piece involved in the move.
     */
    let piece: Piece
    
    /**
     The starting square of the piece.
     */
    let startSquare: BoardSquare
    
    /**
     The ending square of the piece.
     */
    let endSquare: BoardSquare
    
    /**
     Whether this move is a capturing move.
     */
    let isCapture: Bool
    
    // Additional metadata for "special" moves.
    
    /**
     Whether the move is a short castle.
     */
    let isCastleShort: Bool
    
    /**
     Whether the move is a long castle.
     */
    let isCastleLong: Bool
    
    /**
     Whether the move is an en passant capture.
     */
    let isEnPassant: Bool
    
    /**
     If the move is a promotion, the piece type the pawn is promoted to.
     This value is `nil` if the move is not a promotion.
     */
    let promotion: PieceType?
    
    /**
     Unique identifier for a move.
     Moves can be uniquely identified by the piece start square, end square, and promotion (if applicable).
     */
    var id: String {
        return "\(startSquare.notation)\(endSquare.notation)\(promotion?.description ?? "")"
    }
    
    /**
     Compares two moves for equality.
     Two moves must match in all properties to be considered equal.
     */
    public static func == (lhs: Move, rhs: Move) -> Bool { (
        lhs.piece == rhs.piece &&
        lhs.startSquare == rhs.startSquare && lhs.endSquare == rhs.endSquare &&
        lhs.isCastleShort == rhs.isCastleShort && lhs.isCastleLong == rhs.isCastleLong &&
        lhs.isEnPassant == rhs.isEnPassant &&
        lhs.promotion == rhs.promotion
    ) }
    
    /**
     Initializes a normal move.
     A normal move is assumed to not be castling, en passant, or promotion.
     
     - Parameters:
        - piece: The piece to move.
        - startSquare: Starting square of the piece.
        - endSquare: Ending square of the piece.
        - isCapture: Whether the move is capturing a piece.
     */
    init(piece: Piece, startSquare: BoardSquare, endSquare: BoardSquare, isCapture: Bool) {
        self.piece = piece
        self.startSquare = startSquare
        self.endSquare = endSquare
        self.isCapture = isCapture
        
        self.isCastleShort = false
        self.isCastleLong = false
        self.isEnPassant = false
        self.promotion = nil
    }
    
    /**
     Initializes a short castle move.
     
     - Parameters:
        - piece: The piece to move. This must be a king, otherwise the function throws a fatal error.
     */
    init(withPieceCastlingShort piece: Piece) {
        if piece.type != .king {
            fatalError("Attempt to castle short with a non-king piece.")
        }
        let castlingRank = Chessboard.castlingRankFor(color: piece.color)
        
        self.piece = piece
        self.startSquare = BoardSquare(rank: castlingRank, file: Chessboard.kingStartFile)
        self.endSquare = BoardSquare(rank: castlingRank, file: Chessboard.kingShortCastleEndFile)
        self.isCapture = false
        
        self.isCastleShort = true
        self.isCastleLong = false
        self.isEnPassant = false
        self.promotion = nil
    }
    
    /**
     Initializes a long castle move.
     
     - Parameters:
        - piece: The piece to move. This must be a king, otherwise the function throws a fatal error.
     */
    init(withPieceCastlingLong piece: Piece) {
        if piece.type != .king {
            fatalError("Attempt to castle short with a non-king piece.")
        }
        let castlingRank = Chessboard.castlingRankFor(color: piece.color)
        
        self.piece = piece
        self.startSquare = BoardSquare(rank: castlingRank, file: Chessboard.kingStartFile)
        self.endSquare = BoardSquare(rank: castlingRank, file: Chessboard.kingLongCastleEndFile)
        self.isCapture = false
        
        self.isCastleShort = false
        self.isCastleLong = true
        self.isEnPassant = false
        self.promotion = nil
    }
    
    /**
     Initializes an en passant move.
     
     - Parameters:
        - piece: The piece to move. This must be a pawn, otherwise the function throws a fatal error.
        - startSquare: The starting square of the pawn.
        - endSquare: The ending square of the pawn. This is the square where the pawn ends up, not where the opposite color captured pawn is.
     */
    init(withEnPassantByPawn piece: Piece, startSquare: BoardSquare, endSquare: BoardSquare) {
        if piece.type != .pawn {
            fatalError("Attempt to en passant with a non-pawn piece.")
        }

        self.piece = piece
        self.startSquare = startSquare
        self.endSquare = endSquare
        self.isCapture = true
        
        self.isCastleShort = false
        self.isCastleLong = false
        self.isEnPassant = true
        self.promotion = nil
    }
    
    /**
     Initializes a pawn promotion move.
     
     - Parameters:
        - piece: The piece to promote. This must be a pawn, otherwise the function throws a fatal error.
        - toPiece: The piece type to promote to.
        - startSquare: The starting square of the pawn.
        - endSquare: The ending square of the pawn.
        - isCapture: Whether the pawn is capturing a piece in order to promote.
     */
    init(withPawnPromoting piece: Piece, toPiece newPiece: PieceType, startSquare: BoardSquare, endSquare: BoardSquare, isCapture: Bool) {
        if piece.type != .pawn {
            fatalError("Attempted to promote a non-pawn piece.")
        }
        self.piece = piece
        self.startSquare = startSquare
        self.endSquare = endSquare
        self.isCapture = isCapture
        
        self.isCastleShort = false
        self.isCastleLong = false
        self.isEnPassant = false
        self.promotion = newPiece
    }
}
