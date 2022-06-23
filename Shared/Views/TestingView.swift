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
    @EnvironmentObject var state: DocumentState
    @Environment(\.undoManager) var undoManager
    
    @State private var selectedTabIndex = 1
    
    var body: some View {
        HStack {
            
            // Chessboard and Controls
            VStack {
                PlayerNamesView(
                    whitePlayer: state.currentGame.whitePlayerName,
                    blackPlayer: state.currentGame.blackPlayerName,
                    turn: state.currentNode.playerColor.nextColor
                )
                ChessboardView(chessboard: state.currentNode.chessboard, makeMove: state.makeMoveFromCurrentNode)
                GameControlsView()
                Text(state.currentNode.chessboard!.fen)
                GeometryReader { geometry in
                    Text(state.currentNode.moveSequenceUntilCurrentNode())
                        .frame(width: geometry.size.width)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .textSelection(.enabled)
                }
            }
            .fixedSize(horizontal: true, vertical: false)
            .padding()
            
            TabView(selection: $selectedTabIndex) {
                
                GameMetadataView()
                .tabItem {
                    Label("Game", systemImage: "info.circle")
                }
                .tag(0)
                
                // PGN View, move details, variations
                VStack {
                    GameTreeView(tree: state.currentGame.generateNodeLayout())
                    MoveDetailView()
                }
                .tabItem {
                    Label("Moves", systemImage: "square.filled.on.square")
                }
                .tag(1)
                
                EngineView()
                .tabItem {
                    Label("Engine", systemImage: "server.rack")
                }
                .tag(2)
                
            }
            .padding()
        }
        
    }
}

struct TestingView_Previews: PreviewProvider {
    static var previews: some View {
        TestingView()
    }
}
