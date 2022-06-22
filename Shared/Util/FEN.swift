//
//  FEN.swift
//  Holyoke
//
//  Created by Brian Yu on 6/22/22.
//

import Foundation

/**
 Extension to the `Chessboard` class to handle transforming into and out of FEN notation.
 */
extension Chessboard {
    /**
     The FEN of the starting position of a game of chess.
     */
    static let startingPositionFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    
    /**
     Initialize a new `Chessboard` from a given FEN board representation.
     
     - Parameters:
        - fen: the FEN representation of the board.
     
     - Returns: The `Chessboard` corresponding to the FEN notation, or `nil` if the notation is invalid.
     */
    static func initFromFen(fen: String) -> Chessboard? {
        
        // FEN files have six components:
        // board position, active player, castling rights, en passant target, halfmove clock, move number
        let components = fen.components(separatedBy: " ")
        if components.count != 6 {
            return nil
        }
        
        // Start with an empty board
        var position: ChessPosition = Self.emptyPosition()
        
        // Board position consists of ranks separated by a `/` symbol
        let ranks = components[0].components(separatedBy: "/")
        if ranks.count != 8 {
            return nil
        }
        
        // Fill in pieces for each rank
        for (i, rank) in ranks.enumerated() {
            var file = 0
            for char in rank {
                
                // Rank has more than 8 values specified, so notation is invalid
                if file > 7 {
                    return nil
                }
                if let piece = Piece.fromDescription(description: String(char)) {
                    position[i][file] = piece
                    file += 1
                } else if let spaces = Int(String(char)) {
                    file += spaces
                } else {
                    return nil
                }
            }
            
            // At the end of the rank, we should have filled in exactly 8 values
            if file != 8 {
                return nil
            }
        }
        
        // Determine active color and ensure it is valid
        let activeColor: PlayerColor? = components[1] == "w" ? .white : components[1] == "b" ? .black : nil
        guard let activeColor = activeColor else {
            return nil
        }
        
        // Check for all possible castling rights
        let castling = components[2]
        let whiteRightToCastleKingside = castling.contains("K")
        let whiteRightToCastleQueenside = castling.contains("Q")
        let blackRightToCastleKingside = castling.contains("k")
        let blackRightToCastleQueenside = castling.contains("q")
        
        // Check for an en passant target square
        let enPassantTarget: BoardSquare? = BoardSquare.initFromSan(san: components[3])
        
        // Ensure that halfmove clock is a valid number
        let halfmoveClock: Int? = Int(components[4])
        guard let halfmoveClock = halfmoveClock else {
            return nil
        }
        
        // Ensure that move number is a valid number
        let fullmoveNumber: Int? = Int(components[5])
        guard let fullmoveNumber = fullmoveNumber else {
            return nil
        }
        
        // FEN is valid, return the corresponding chessboard
        let board = Chessboard(
            position: position,
            playerToMove: activeColor, enPassantTarget: enPassantTarget, fullmoveNumber: fullmoveNumber, halfmoveClock: halfmoveClock,
            whiteRightToCastleKingside: whiteRightToCastleKingside, whiteRightToCastleQueenside: whiteRightToCastleQueenside,
            blackRightToCastleKingside: blackRightToCastleKingside, blackRightToCastleQueenside: blackRightToCastleQueenside
        )
        board.computeAndSaveLegalMoves()
        return board
    }
    
    /**
     Initialize a new `Chessboard` in the starting position of a game of chess.
     
     - Returns: A new `Chessboard` in the starting position.
     */
    static func initInStartingPosition() -> Chessboard { initFromFen(fen: Self.startingPositionFEN)! }
    
    /**
     FEN representation of the current chessboard.
     */
    var fen: String {
        // Fill in state of board based on all pieces and spaces
        var boardState = ""
        for (i, rank) in self.position.enumerated() {
            var spaces = 0
            for piece in rank {
                guard let piece = piece else {
                    spaces += 1
                    continue
                }
                if spaces > 0 {
                    boardState += String(spaces)
                    spaces = 0
                }
                boardState += piece.description
            }
            if spaces > 0 {
                boardState += String(spaces)
            }
            if i < 7 {
                boardState += "/"
            }
        }
        
        // Active player must be either "w" or "b"
        let activeColor = self.playerToMove == .white ? "w" : "b"
        
        // Castling rights are "-" if none, otherwise some combination of "KQkq"
        var castling = ""
        if self.whiteRightToCastleKingside {
            castling += "K"
        }
        if self.whiteRightToCastleQueenside {
            castling += "Q"
        }
        if self.blackRightToCastleKingside {
            castling += "k"
        }
        if self.blackRightToCastleQueenside {
            castling += "q"
        }
        if castling.count == 0 {
            castling = "-"
        }
        
        // En passant target is "-" if none, otherwise the SAN notation of a square
        let enPassant = self.enPassantTarget?.notation ?? "-"
        
        // Combine all six components to get the FEN notation for the board
        return "\(boardState) \(activeColor) \(castling) \(enPassant) \(halfmoveClock) \(fullmoveNumber)"
    }
}
