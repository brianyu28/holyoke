//
//  ChessboardUCI.swift
//  Holyoke (macOS)
//
//  Created by Brian Yu on 6/22/22.
//

import Foundation

/**
 `Chessboard` logic for interpreting a UCI move sequence.
 */
extension Chessboard {
    /**
     Converts a move sequence from a UCI engine into SAN.
     
     - Parameters:
        - sequence: Array of moves in long algebraic notation (e.g. "e2e4").
     
     - Returns: A pair (`Move?`, `String`) where the `Move` is the first move of the line,
     and the `String` is the SAN notation for the line.
     */
    func movesFromUCIVariation(sequence: [String]) -> (Move?, String) {
        var firstMove: Move? = nil
        var line: String = ""
        
        var currentBoard: Chessboard = self
        
        for moveText in sequence {
            if moveText.count != 4 && moveText.count != 5 {
                continue
            }
            
            let startFile = Chessboard.fileFromSan(string: String(moveText[moveText.index(moveText.startIndex, offsetBy: 0)])) ?? 0
            let startRank = Int(String(moveText[moveText.index(moveText.startIndex, offsetBy: 1)])) ?? 0
            let startSquare = BoardSquare(rank: 8 - startRank, file: startFile)
            let endFile = Chessboard.fileFromSan(string: String(moveText[moveText.index(moveText.startIndex, offsetBy: 2)])) ?? 0
            let endRank = Int(String(moveText[moveText.index(moveText.startIndex, offsetBy: 3)])) ?? 0
            let endSquare = BoardSquare(rank: 8 - endRank, file: endFile)
            let promotion: PieceType? = moveText.count == 5 ? PieceType.fromDescription(description: String(moveText[moveText.index(moveText.startIndex, offsetBy: 4)])) : nil
            
            for (notation, move) in currentBoard.legalMoves {
                if move.startSquare == startSquare && move.endSquare == endSquare && move.promotion == promotion {
                    
                    if move.piece.color == .white {
                        line += String(currentBoard.fullmoveNumber) + ". " + notation + " "
                    } else if firstMove == nil {
                        line += String(currentBoard.fullmoveNumber) + "... " + notation + " "
                    } else {
                        line += notation + " "
                    }
                    
                    if firstMove == nil {
                        firstMove = move
                    }
                    
                    currentBoard = currentBoard.getChessboardAfterMove(move: move)
                    break
                }
            }
        }
        
        return (firstMove, line)
    }
}
