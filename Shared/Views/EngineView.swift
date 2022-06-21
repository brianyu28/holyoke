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
                    engine.stop(clearLines: false)
                }
            } else {
                Button("Start Engine") {
                    guard let board = document.currentNode.chessboard else {
                        return
                    }
                    engine.run(board: board)
                }
            }
            
            List {
                ForEach(engine.lines.indices, id: \.self) { i in
                    if let line = engine.lines[i] {
                        Text("\(line.cp, specifier: "%.2f") (d = \(line.depth)) \(line.variation)")
                        .onTapGesture {
                            document.makeMoveOnBoard(move: line.move)
                            
                        }
                    }
                }
            }
        }
        .onReceive(document.$currentNode) { node in
            let isRunning = engine.isRunningEngine
            if node.chessboard?.fen != engine.currentBoard?.fen {
                engine.stop(clearLines: true)
                guard let board = node.chessboard else {
                    return
                }
                if isRunning {
                    engine.run(board: board)
                }
            }
        }
    }
}

struct EngineView_Previews: PreviewProvider {
    static var previews: some View {
        EngineView(document: HolyokeDocument())
    }
}
