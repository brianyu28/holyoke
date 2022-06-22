//
//  ChessboardView.swift
//  Holyoke
//
//  Created by Brian Yu on 6/14/22.
//

import SwiftUI

struct ChessboardSquareStyle {
    let darkSquareColor: Color
    let lightSquareColor: Color
    
    static var defaultStyle: ChessboardSquareStyle {
        return ChessboardSquareStyle(
            darkSquareColor: Color(red: 0.541, green: 0.451, blue: 0.298),
            lightSquareColor: Color(red: 0.839, green: 0.769, blue: 0.647)
        )
    }
}

struct ChessboardView: View {
    var chessboard: Chessboard?
    
    let makeMove: (Move) -> ()
    
    @State var selectedSquare: BoardSquare? = nil
    @State var legalMovesForSelectedPiece: [BoardSquare: Move] = [:]
    
    let squareSize: CGFloat = 80
    let squareStyle : ChessboardSquareStyle = .defaultStyle

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0...7, id:\.self) { rank in
                HStack(spacing: 0) {
                    ForEach(0...7, id:\.self) { file in
                        ZStack {
                            
                            Rectangle()
                                .fill(rank % 2 == file % 2 ? squareStyle.lightSquareColor : squareStyle.darkSquareColor)
                                .frame(width: squareSize, height: squareSize)
                            
                            if let _ = legalMovesForSelectedPiece[BoardSquare(rank: rank, file: file)] {
                                if let _ = chessboard?.pieceAt(rank: rank, file: file) {
                                    Circle()
                                        .fill(Color(red: 0, green: 0, blue: 0, opacity: 0.5))
                                        .frame(width: squareSize * 1.0, height: squareSize * 1.0)
                                } else {
                                    Circle()
                                        .fill(Color(red: 0, green: 0, blue: 0, opacity: 0.5))
                                        .frame(width: squareSize * 0.4, height: squareSize * 0.4)
                                }
                            }
                            
                            if selectedSquare?.rank == rank && selectedSquare?.file == file {
                                Rectangle()
                                    .fill(Color(red: 0, green: 0, blue: 0, opacity: 0.5))
                                    .frame(width: squareSize, height: squareSize)
                            }
                            
                            if let piece = chessboard?.pieceAt(rank: rank, file: file) {
                                Image(piece.assetName)
                                    .resizable()
                                    .frame(width: squareSize, height: squareSize)
                            }
                            
                        }
                        .onTapGesture {
                            guard let chessboard = chessboard else {
                                return
                            }

                            
                            if let legalMove = legalMovesForSelectedPiece[BoardSquare(rank: rank, file: file)] {
                                selectedSquare = nil
                                legalMovesForSelectedPiece = [:]
                                makeMove(legalMove)
                                return
                            }
                            
                            // Select a piece to move
                            if let piece = chessboard.pieceAt(rank: rank, file: file) {
                                if piece.color == chessboard.playerToMove {
                                    let newSelectedSquare = BoardSquare(rank: rank, file: file)
                                    if selectedSquare != newSelectedSquare {
                                        selectedSquare = newSelectedSquare
                                        
                                        // Determine legal moves for the currently selected piece
                                        // TODO: Handle pawn promotion
                                        let legalMoves = chessboard.legalMovesForPieceAtSquare(square: newSelectedSquare)
                                        var legalMovesDict: [BoardSquare:Move] = [:]
                                        for move in legalMoves {
                                            legalMovesDict[move.endSquare] = move
                                        }
                                        legalMovesForSelectedPiece = legalMovesDict
                                    } else {
                                        selectedSquare = nil
                                    }
                                } else {
                                    selectedSquare = nil
                                }
                            } else {
                                selectedSquare = nil
                            }
                            
                            if selectedSquare == nil {
                                legalMovesForSelectedPiece = [:]
                            }
                        }
                    }
                }
            }
        }
        
    }
}

struct ChessboardView_Previews: PreviewProvider {
    static var previews: some View {
        ChessboardView(chessboard: Chessboard.initInStartingPosition(), makeMove: { _ in })
    }
}
