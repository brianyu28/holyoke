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
        VStack {
            ChessboardView(chessboard: document.chessboard, makeMove: document.makeMoveOnBoard)
            
            VStack {
                if document.currentNode.moveNumber > 0 {
                    Text("\(document.currentNode.moveNumber)\(document.currentNode.playerColor == .white ? "." : "...") \(document.currentNode.move?.description ?? "")")
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
