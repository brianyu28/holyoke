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
            ChessboardView(chessboard: document.chessboard)
            VStack {
                Text("Moves")
                ForEach(document.chessboard.legalMoves) { move in
                    Button(move.longDescription) {
                        document.makeMoveOnBoard(move: move)
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
        TestingView(document: HolyokeDocument())
    }
}
