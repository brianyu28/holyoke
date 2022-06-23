//
//  ContentView.swift
//  Shared
//
//  Created by Brian Yu on 6/8/22.
//

import SwiftUI
import Antlr4

struct ContentView: View {
    @StateObject var state: DocumentState
    
    var body: some View {
        MainDocumentView()
            .environmentObject(state)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView(state: DocumentState.sampleDocumentState)
    }
}
