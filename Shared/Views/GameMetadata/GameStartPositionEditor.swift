//
//  GameStartPositionEditor.swift
//  Holyoke
//
//  Created by Brian Yu on 6/21/22.
//

import SwiftUI

struct GameStartPositionEditor: View {
    @ObservedObject var document: HolyokeDocument
    
    @State private var newStartingPosition: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("**Starting Position**")
            Text(document.currentGame.startingPosition.fen)
                .textSelection(.enabled)
            
            if (document.currentGame.root.variations.count == 0) {
                TextField("New Starting Position", text: $newStartingPosition)
                Button("Update Starting Position") {
                    let root = document.currentGame.root
                    if root.variations.count != 0 {
                        return
                    }
                    guard let board = Chessboard.initFromFen(fen: newStartingPosition) else {
                        return
                    }
                    document.currentGame.setStartingPosition(fen: newStartingPosition)
                    root.chessboard = board
                    root.setPlayerToMove(playerToMove: board.playerToMove)
                    newStartingPosition = ""
                    document.forceManualRefresh()
                }
            }
        }
    }
}

struct GameStartPositionEditor_Previews: PreviewProvider {
    static var previews: some View {
        GameStartPositionEditor(document: HolyokeDocument())
    }
}
