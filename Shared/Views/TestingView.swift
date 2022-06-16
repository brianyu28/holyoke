//
//  TestingView.swift
//  Holyoke
//
// A view for testing other views in the app.
// Not meant to be part of any production view.
//
//  Created by Brian Yu on 6/14/22.
//

import SwiftUI

struct TestingView: View {
    @ObservedObject var chessboard: Chessboard
    
    var body: some View {
        HStack {
            ChessboardView(chessboard: chessboard)
            VStack {
                Text("Moves")
                ForEach(chessboard.getLegalMoves()) { move in
                    Button("\(move.piece.description) \(move.currentSquare.notation)-\(move.newSquare.notation)") {
                        chessboard.makeMoveOnBoard(move: move)
                        print(chessboard.getLegalMoves())
                    }
                    .frame(minWidth: 100, maxWidth: .infinity)
                }
            }
            .padding()
        }
    }
}

struct TestingView_Previews: PreviewProvider {
    static var previews: some View {
        TestingView(chessboard: Chessboard.initInStartingPosition())
    }
}
