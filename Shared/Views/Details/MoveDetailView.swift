//
//  MoveDetailView.swift
//  Holyoke
//
//  Created by Brian Yu on 6/17/22.
//

import SwiftUI

struct MoveDetailView: View {
    @EnvironmentObject var state: DocumentState
    
    var body: some View {
        HStack {
            VStack {
                if state.currentNode.moveNumber > 0 {
                    Text(state.currentNode.pgnNotation(withMoveNumber: true, withComments: false))
                    TextEditor(text: $state.currentNode.braceComment)
                }
                List {
                    ForEach(state.currentNode.variations) { variation in
                        Text(variation.pgnNotation(withMoveNumber: true, withComments: false))
                            .onTapGesture {
                                guard let move = state.currentNode.chessboard?.legalMoves[variation.move ?? ""] else {
                                    return
                                }
                                state.makeMoveFromCurrentNode(move: move)
                            }
                        
                    }
                }
            }
        }
        
    }
}

struct MoveDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MoveDetailView()
    }
}
