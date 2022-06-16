//
//  ContentView.swift
//  Shared
//
//  Created by Brian Yu on 6/8/22.
//

import SwiftUI
import Antlr4

struct ContentView: View {
    @Binding var document: HolyokeDocument
    
    var chessboard : Chessboard = Chessboard.initInDebugPosition() // TODO: don't use debug position
    
    var body: some View {
        TestingView(chessboard: chessboard)
            .onAppear {
                let examplePGN = """
                """
                let games = PGNGameListener.parseGamesFromPGNString(pgn: examplePGN)
                print(games)
                
            }
    }

//    var body: some View {
//        TextEditor(text: $document.text)
//    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(HolyokeDocument(pgnText: "")), chessboard: Chessboard.initInStartingPosition())
    }
}
