//
//  ContentView.swift
//  Shared
//
//  Created by Brian Yu on 6/8/22.
//

import SwiftUI
import Antlr4

struct ContentView: View {
    @ObservedObject var document: HolyokeDocument
    
    var body: some View {
        TestingView(document: document)
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
        ContentView(document: HolyokeDocument())
    }
}
