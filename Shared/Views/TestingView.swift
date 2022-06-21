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
    @Environment(\.undoManager) var undoManager
    
    @ObservedObject var document: HolyokeDocument
    
    @State private var selectedTabIndex = 1
    
    var body: some View {
        HStack {
            
            // Chessboard and Controls
            VStack {
                PlayerNamesView(whitePlayer: document.currentGame.whitePlayerName, blackPlayer: document.currentGame.blackPlayerName, turn: document.currentNode.playerColor.nextColor)
                ChessboardView(chessboard: document.currentNode.chessboard, makeMove: document.makeMoveOnBoard)
                GameControlsView(document: document)
                Text(document.currentNode.chessboard!.fen)
                GeometryReader { geometry in
                    Text(document.currentNode.moveSequenceUntilCurrentNode())
                        .frame(width: geometry.size.width)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .textSelection(.enabled)
                }
            }
            .fixedSize(horizontal: true, vertical: false)
            .padding()
            
            TabView(selection: $selectedTabIndex) {
                
                GameMetadataView(document: document)
                .tabItem {
                    Label("Game", systemImage: "info.circle")
                }
                .tag(0)
                
                // PGN View, move details, variations
                VStack {
                    GameTreeView(document: document, tree: document.currentGame.generateNodeLayout())
                    MoveDetailView(document: document)
                }
                .tabItem {
                    Label("Moves", systemImage: "square.filled.on.square")
                }
                .tag(1)
                
                EngineView(document: document)
                .tabItem {
                    Label("Engine", systemImage: "server.rack")
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
