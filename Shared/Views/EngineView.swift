//
//  EngineView.swift
//  Holyoke
//
//  Created by Brian Yu on 6/20/22.
//

import SwiftUI

struct EngineView: View {
    
    @ObservedObject var document: HolyokeDocument
    @ObservedObject var engine = ChessEngine.sharedInstance
    
    var body: some View {
        VStack {
            if engine.isRunningEngine {
                Button("Stop Engine") {
                    engine.stop()
                }
                
                List {
                    ForEach(engine.lines.indices, id: \.self) { i in
                        Text(engine.lines[i])
                    }
                }
            } else {
                Button("Start Engine") {
                    guard let board = document.currentNode.chessboard else {
                        return
                    }
                    engine.run(board: board)
                }
            }
        }
        .onReceive(document.$currentNode) { node in
            if engine.isRunningEngine && node.chessboard?.fen != engine.currentBoard?.fen {
                engine.stop()
                guard let board = node.chessboard else {
                    return
                }
                engine.run(board: board)
            }
        }
    }
}

struct EngineView_Previews: PreviewProvider {
    static var previews: some View {
        EngineView(document: HolyokeDocument())
    }
}
