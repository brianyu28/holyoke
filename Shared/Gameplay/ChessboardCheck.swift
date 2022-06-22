//
//  ChessboardCheck.swift
//  Holyoke
//
//  Created by Brian Yu on 6/22/22.
//

import Foundation

/**
 Logic for handling whether a player is in check or checkmate.
 */
extension Chessboard {
    /**
     Determines whether a player's King is in check on the chessboard.
     
     - Parameters:
        - player: The color of the player.
     
     - Returns: `true` if the player is in check, `false` otherwise.
     */
    func isPlayerInCheck(player: PlayerColor) -> Bool {
        
        // Find the king
        var kingRank: Int? = nil
        var kingFile: Int? = nil
        for rank in 0...7 {
            for file in 0...7 {
                if let piece = self.pieceAt(rank: rank, file: file) {
                    if piece.type == .king && piece.color == player {
                        kingRank = rank
                        kingFile = file
                    }
                }
            }
        }
        
        // Ensure the king is actually on the board
        guard let kingRank = kingRank, let kingFile = kingFile else {
            return true
        }
        
        // Check if a rook or queen is attacking the king
        for (rankDirection, fileDirection) in Self.horizontalDirections {
            var candidateSquare = BoardSquare(rank: kingRank + rankDirection, file: kingFile + fileDirection)
            while (true) {
                if !candidateSquare.isValidSquare {
                    break
                }
                let piece = self.pieceAt(rank: candidateSquare.rank, file: candidateSquare.file)
                if piece != nil && piece!.color == player.nextColor && (piece!.type == .rook || piece!.type == .queen) {
                    return true
                } else if piece != nil {
                    break
                }
                candidateSquare = BoardSquare(rank: candidateSquare.rank + rankDirection, file: candidateSquare.file + fileDirection)
            }
        }
        
        // Check if a bishop or queen is attacking the king
        for (rankDirection, fileDirection) in Self.diagionalDirections {
            var candidateSquare = BoardSquare(rank: kingRank + rankDirection, file: kingFile + fileDirection)
            while (true) {
                if !candidateSquare.isValidSquare {
                    break
                }
                let piece = self.pieceAt(rank: candidateSquare.rank, file: candidateSquare.file)
                if piece != nil && piece!.color == player.nextColor && (piece!.type == .bishop || piece!.type == .queen) {
                    return true
                } else if piece != nil {
                    break
                }
                candidateSquare = BoardSquare(rank: candidateSquare.rank + rankDirection, file: candidateSquare.file + fileDirection)
            }
        }
        
        // Check if a knight is attacking the king
        for (rankDirection, fileDirection) in Self.diagionalDirections {
            let candidateSquares = [
                BoardSquare(rank: kingRank + rankDirection * 2, file: kingFile + fileDirection * 1),
                BoardSquare(rank: kingRank + rankDirection * 1, file: kingFile + fileDirection * 2),
            ]
            for candidateSquare in candidateSquares {
                if let piece = self.pieceAt(rank: candidateSquare.rank, file: candidateSquare.file) {
                    if piece.color == player.nextColor && piece.type == .knight {
                        return true
                    }
                }
            }
        }
        
        // Check if a pawn is attacking the king
        let candidateSquares = [
            BoardSquare(rank: player == .white ? kingRank - 1 : kingRank + 1, file: kingFile - 1),
            BoardSquare(rank: player == .white ? kingRank - 1 : kingRank + 1, file: kingFile + 1),
        ]
        for candidateSquare in candidateSquares {
            if let piece = self.pieceAt(rank: candidateSquare.rank, file: candidateSquare.file) {
                if piece.color == player.nextColor && piece.type == .pawn {
                    return true
                }
            }
        }
        
        return false
    }
    
    /**
     Determines whether a player is in checkmate.
     
     - Parameters:
        - player: The color of the player.
     
     - Returns: `true` if player is in checkmate, `false` otherwise.
     */
    func isPlayerInCheckmate(player: PlayerColor) -> Bool {
        // It must be the player's turn for them to be in checkmate
        if self.playerToMove != player {
            return false
        }
        
        // Player must be in check to be in checkmate
        if !self.isPlayerInCheck(player: player) {
            return false
        }
        
        // If player has existing legal moves, they're not in checkmate
        if !self.legalMoves.isEmpty {
            return false
        }
        
        // Otherwise, compute moves in case they weren't already computed
        self.computeAndSaveLegalMoves()
        return self.legalMoves.isEmpty
    }
}
