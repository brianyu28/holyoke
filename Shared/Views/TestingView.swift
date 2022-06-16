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
    @ObservedObject var document: HolyokeDocument
    
    var body: some View {
        HStack {
            ChessboardView(chessboard: document.chessboard, makeMove: document.makeMoveOnBoard)
            
//            VStack {
//                Text("Moves")
//                ForEach(Array(document.chessboard.legalMoves.keys.sorted()), id: \.self) { moveName in
//                    Button(moveName) {
//                        if let move = document.chessboard.legalMoves[moveName] {
//                            document.makeMoveOnBoard(move: move)
//                        }
//                    }
//                    .frame(minWidth: 100, maxWidth: .infinity)
//                }
//            }
//            .padding()
            
        }
    }
}

struct TestingView_Previews: PreviewProvider {
    static var previews: some View {
        TestingView(document: HolyokeDocument())
    }
}
