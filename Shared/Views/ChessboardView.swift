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
    let chessboard: Chessboard
    
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
                            
                            if let piece = chessboard.pieceAt(rank: rank, file: file) {
                                Image(piece.assetName)
                                    .resizable()
                                    .frame(width: squareSize, height: squareSize)
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
        ChessboardView(chessboard: Chessboard.initInStartingPosition())
    }
}
