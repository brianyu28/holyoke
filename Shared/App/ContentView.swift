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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: HolyokeDocument())
    }
}
