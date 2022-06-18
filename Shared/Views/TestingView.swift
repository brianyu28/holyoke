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
                Text(document.currentNode.moveSequenceUntilCurrentNode())
            }
            
            // PGN View, move details, variations
            VStack {
                GameTreeView(document: document, tree: document.currentGame.generateNodeLayout())
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
