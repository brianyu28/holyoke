//
//  ContentView.swift
//  Shared
//
//  Created by Brian Yu on 6/8/22.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: HolyokeDocument
    
    var chessboard : Chessboard = Chessboard()
    
    var body: some View {
        ChessboardView(chessboard: chessboard)
    }

//    var body: some View {
//        TextEditor(text: $document.text)
//            .onAppear {
//                print("test")
//                let board = Chessboard()
//                print(board)
//            }
//    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(HolyokeDocument()), chessboard: Chessboard())
    }
}
