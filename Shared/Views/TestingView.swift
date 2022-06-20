//
//  TestingView.swift
//  Holyoke
//
// A view for testing UI elements.
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
                PlayerNamesView(whitePlayer: document.currentGame.whitePlayerName, blackPlayer: document.currentGame.blackPlayerName, turn: document.currentNode.playerColor.nextColor)
                ChessboardView(chessboard: document.currentNode.chessboard, makeMove: document.makeMoveOnBoard)
                GameControlsView(document: document)
                Text(document.currentNode.moveSequenceUntilCurrentNode())
            }
            .fixedSize(horizontal: true, vertical: false)
            .padding()
            
            // PGN View, move details, variations
            VStack {
                GameTreeView(document: document, tree: document.currentGame.generateNodeLayout())
                MoveDetailView(document: document)
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
