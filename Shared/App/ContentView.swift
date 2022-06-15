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
    
    var chessboard : Chessboard = Chessboard()
    
    var body: some View {
        ChessboardView(chessboard: chessboard)
            .onAppear {
                let examplePGN = """
[Event "KasparovChess GP g/60"]
[Site "Internet INT"]
[Date "2000.02.17"]
[Round "3.2"]
[White "Adams, Michael"]
[Black "Kasparov, Gary"]
[Result "1/2-1/2"]
[WhiteElo "2715"]
[BlackElo "2851"]
[ECO "B90u"]
[EventDate "2000.02.09"]

1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 a6 6.Be3 e5 7.Nb3 Be6 8.f3
Nbd7 9.Qd2 b5 10.g4 Nb6 11.g5 Nfd7 12.Nd5 Rc8 13.Nxb6 Nxb6 14.Qa5 Nc4 15.
Bxc4 bxc4 16.Qxd8+ Kxd8 17.Na5 h6 18.gxh6 g6 19.O-O-O Kc7 20.b3 Bxh6 21.
Bxh6 Rxh6 22.bxc4 g5 23.Rhg1 Kb6 24.Nb3 Bxc4 {asdf} 25.Rd2 Rg6 26.Kb2 Kc7 27.Rdg2
Rh6 28.Nd2 Be6 29.Rxg5 Rxh2 30.R5g2 Rh3 31.c4 Kd7 32.Kc3 a5 33.Rg3 Rhh8
34.Rc1 Rc7 35.Rgg1 Rhc8 36.Kd3 Ke7 37.Rc3 d5 38.exd5 Bxd5 39.Re1 f6 40.f4
Kd6 41.fxe5+ fxe5 42.Rec1 Bc6 43.Kc2 Rg7 44.Rd3+ Kc7 45.Re3 Rd8 46.Kc3 Rg2
47.Rc2 a4 48.Nb1 Rxc2+ 49.Kxc2 Kd6 50.Rd3+ Ke7 51.Rxd8 Kxd8 52.Kc3 Kd7 53.
Kb4 Kd6 54.Nc3 e4 55.Nd1 Ke5 56.Kc5 Be8 57.a3 Kf4 58.Kd4 Kf3 59.Ne3 Bc6
60.c5 Kf4 61.Nc4 Bb5 62.Nb6 Bc6 63.Nc4 Bb5 64.Ne3 1/2-1/2
"""
                do {
                    let inputStream = ANTLRInputStream(examplePGN)
                    let lexer = PGNLexer(inputStream)
                    let tokenStream = CommonTokenStream(lexer)
                    let parser = try PGNParser(tokenStream)
                    let expressionContext = try parser.pgn_database()
                    let listener = PGNGameListener()
                    try ParseTreeWalker().walk(listener, expressionContext)
                } catch {
                    print("Caught error")
                }
                
            }
    }

//    var body: some View {
//        TextEditor(text: $document.text)
//    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(HolyokeDocument()), chessboard: Chessboard())
    }
}
