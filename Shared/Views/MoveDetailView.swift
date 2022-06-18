//
//  MoveDetailView.swift
//  Holyoke
//
//  Created by Brian Yu on 6/17/22.
//

import SwiftUI

struct MoveDetailView: View {
    
    @ObservedObject var document: HolyokeDocument
    
    var body: some View {
        HStack {
            VStack {
                if document.currentNode.moveNumber > 0 {
                    Text(document.currentNode.pgnNotation(withMoveNumber: true, withComments: false))
                    TextEditor(text: $document.currentNode.braceComment)
                }
                List {
                    ForEach(document.currentNode.variations) { variation in
                        Text(variation.pgnNotation(withMoveNumber: true, withComments: false))
                            .onTapGesture {
                                guard let move = document.chessboard.legalMoves[variation.move ?? ""] else {
                                    return
                                }
                                document.makeMoveOnBoard(move: move)
                            }
                        
                    }
                }
            }
        }
        
    }
}

struct MoveDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MoveDetailView(document: HolyokeDocument())
    }
}
