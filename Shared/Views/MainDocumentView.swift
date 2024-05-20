//
//  MainDocumentView.swift
//  Holyoke
//
//  Created by Brian Yu on 6/14/22.
//

import SwiftUI

struct MainDocumentView: View {
    @EnvironmentObject var state: DocumentState
    @Environment(\.undoManager) var undoManager
    
    @State private var selectedTabIndex = 1
    
    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .top) {
                
                // Chessboard and Controls
                VStack {
                    PlayerNamesView(
                        whitePlayer: state.currentGame.whitePlayerName,
                        blackPlayer: state.currentGame.blackPlayerName,
                        turn: state.currentNode.playerColor.nextColor
                    )
                    ChessboardView(chessboard: state.currentNode.chessboard, makeMove: state.makeMoveFromCurrentNode, squareSize: (geo.size.height - 100) / 8)
                        .frame(width: geo.size.height - 100, height: geo.size.height - 100)
                    GameControlsView()
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
                    VStack(alignment: .leading) {
                        GameTreeView(tree: state.currentGame.generateNodeLayout())
                        MoveDetailView()
                    }
                    .tabItem {
                        Label("Moves", systemImage: "square.filled.on.square")
                    }
                    .tag(1)
                    
                    #if os(macOS)
                    EngineView()
                    .tabItem {
                        Label("Engine", systemImage: "server.rack")
                    }
                    .tag(2)
                    #endif
                    
                }
                .padding()
            }
        }
    }
}

struct MainDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        MainDocumentView()
    }
}
