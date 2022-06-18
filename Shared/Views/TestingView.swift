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
            
            // Chessboard and Controls
            VStack {
                ChessboardView(chessboard: document.chessboard, makeMove: document.makeMoveOnBoard)
                GameControlsView(document: document)
                
                VStack {
                    if document.currentNode.moveNumber > 0 {
                        Text("\(document.currentNode.moveNumber)\(document.currentNode.playerColor == .white ? "." : "...") \(document.currentNode.move?.description ?? "")")
                    }
                }
                .padding()
                
            }
            
            // PGN View, move details, variations
            VStack {
                GameTreeView(document: document)
                MoveDetailView(document: document)
            }
        }
        
    }
}

struct TestingView_Previews: PreviewProvider {
    static var previews: some View {
        TestingView(document: HolyokeDocument())
    }
}
