//
//  GameStartPositionEditor.swift
//  Holyoke
//
//  Created by Brian Yu on 6/21/22.
//

import SwiftUI

struct GameStartPositionEditor: View {
    @EnvironmentObject var state: DocumentState
    
    @State private var newStartingPosition: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("**Starting Position**")
            Text(state.currentGame.startingPosition.fen)
                .textSelection(.enabled)
            
            if (state.currentGame.root.variations.count == 0) {
                TextField("New Starting Position", text: $newStartingPosition)
                Button("Update Starting Position") {
                    let root = state.currentGame.root
                    if root.variations.count != 0 {
                        return
                    }
                    guard let board = Chessboard.initFromFen(fen: newStartingPosition) else {
                        return
                    }
                    state.currentGame.setStartingPosition(fen: newStartingPosition)
                    root.setChessboardForNode(board: board)
                    newStartingPosition = ""
                    state.forceManualRefresh()
                }
            } else {
                Text("**Current Position**")
                    .padding(.top)
                Text(state.currentNode.chessboard!.fen)
                    .textSelection(.enabled)
            }
        }
    }
}

struct GameStartPositionEditor_Previews: PreviewProvider {
    static var previews: some View {
        GameStartPositionEditor()
    }
}
