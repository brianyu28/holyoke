//
//  Chessboard.swift
//  Holyoke (iOS)
//
//  Created by Brian Yu on 6/11/22.
//

import Foundation

/**
 A chess position is represented as a 8x8 2D array of pieces.
 Each row represents a rank, starting with the 8th rank.
 Values of `nil` represent empty squares.
 */
typealias ChessPosition = [[Piece?]]

/**
 Represents a chessboard.
 */
class Chessboard : CustomStringConvertible {
    
    /**
     The current position of pieces on the chessboard.
     */
    var position: ChessPosition
    
    /**
     The player whose turn it is to move on the current board.
     */
    var playerToMove: PlayerColor
    
    /**
     If a pawn has just moved two spaces, the square over which it passed.
     This is used to determine en passant rights for the next player.
     */
    var enPassantTarget: BoardSquare?
    
    /**
     Whether White has the right to castle kingside.
     */
    var whiteRightToCastleKingside: Bool
    
    /**
     Whether White has the right to castle queenside.
     */
    var whiteRightToCastleQueenside: Bool
    
    /**
     Whether Black has the right to castle kingside.
     */
    var blackRightToCastleKingside: Bool
    
    /**
     Whether Black has the right to castle queenside.
     */
    var blackRightToCastleQueenside: Bool
    
    /**
     Move number of the current board.
     Begins at 1 on the first turn, increments by 1 after each turn by Black.
     */
    var fullmoveNumber: Int
    
    /**
     The number of half-moves that have passed since the last non-capture, non-pawn move.
     This value starts at 0 and increases by 1 for every non-capture, non-pawn move.
     */
    var halfmoveClock: Int
    
    /**
     The legal moves on the current chessboard.
     This is represented as a dictionary mapping SAN notation for moves to a `Move`.
     For efficiency, this is not computed for every chessboard, needs to be computed before use.
     */
    var legalMoves: [String: Move]
    
    /**
     The four possible diagional directions, for use in movement by knights, bishops, queens, and kings.
     */
    static let diagionalDirections = [(1, 1), (1, -1), (-1, 1), (-1, -1)]
    
    /**
     The four possible horizontal directions, for use in movement by rooks, queens, and kings.
     */
    static let horizontalDirections = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    
    /**
     Initializes a new chessboard.
     
     - Parameters:
        - position: The position of the board.
        - playerToMove: Whose players turn it is on the current board.
        - enPassantTarget: The square over which a pawn has just passed if it moved two spaces, `nil` if inapplicable.
        - fullmoveNumber: The number of the current move, incremented after each Black turn.
        - halfmoveClock: The number of half-moves that have passed since the last pawn move or capture.
        - whiteRightToCastleKingside: Whether White has the right to castle kingside, `true` by default.
        - whiteRightToCastleQueenside: Whether White has the right to castle queenside, `true` by default.
        - blackRightToCastleKingside: Whether Black has the right to castle kingside, `true` by default.
        - blackRightToCastleQueenside: Whether Black has the right to castle queenside, `true` by default.
        - computeLegalMoves: Whether the legal moves should be computed and saved for the current position, `true` by default.
     */
    init(position: ChessPosition, playerToMove: PlayerColor, enPassantTarget: BoardSquare?, fullmoveNumber: Int, halfmoveClock: Int,
         whiteRightToCastleKingside: Bool = true, whiteRightToCastleQueenside: Bool = true,
         blackRightToCastleKingside : Bool = true, blackRightToCastleQueenside: Bool = true) {
        self.position = position
        self.playerToMove = playerToMove
        self.enPassantTarget = enPassantTarget
        self.fullmoveNumber = fullmoveNumber
        self.halfmoveClock = halfmoveClock
        self.legalMoves = [:]
        
        self.whiteRightToCastleKingside = whiteRightToCastleKingside
        self.whiteRightToCastleQueenside = whiteRightToCastleQueenside
        self.blackRightToCastleKingside = blackRightToCastleKingside
        self.blackRightToCastleQueenside = blackRightToCastleQueenside
    }
    
    /**
     String representation of a board to satisfy `CustomStringConvertible`.
     Used for debugging when printing a chessboard.
     */
    var description : String {
        var representation = ""
        for rank in position {
            for square in rank {
                if let square = square {
                    representation += square.description
                } else {
                    representation += "_"
                }
            }
            representation += "\n"
        }
        return representation
    }
    
    /**
     Returns whatever is located at given rank and file on the chessboard.
     
     - Parameters:
        - rank: The square's rank.
        - file: The square's file.
     
     - Returns: The piece located at the square, or `nil` if there is no piece at the square.
     */
    func pieceAt(rank: BoardRank, file: BoardFile) -> Piece? {
        if Self.isValidRank(rank: rank) && Self.isValidFile(file: file) {
            return position[rank][file]
        }
        return nil
    }
    
    /**
     Returns all of a player's pieces on a chessboard.
     
     - Parameters:
        - player: Color of the player whose pieces should be returned.
     
     - Returns: An array of `(Piece, BoardSquare)` pairs, each representing a piece and its square.
     */
    func piecesForPlayer(player: PlayerColor) -> [(Piece, BoardSquare)] {
        var pieces: [(Piece, BoardSquare)] = []
        for rankIndex in 0...7 {
            for fileIndex in 0...7 {
                if let piece = position[rankIndex][fileIndex] {
                    if piece.color == player {
                        pieces.append((piece, BoardSquare(rank: rankIndex, file: fileIndex)))
                    }
                }
            }
        }
        return pieces
    }

    /**
     Generates a new empty chess position.
     
     - Returns: A `ChessPosition` representing a board with all empty squares.
     */
    static func emptyPosition() -> ChessPosition {
        return [[Piece?]](repeating: [Piece?](repeating: nil, count: 8), count: 8)
    }
}
