//
//  GamePicker.swift
//  Holyoke
//
//  Created by Brian Yu on 6/21/22.
//

import SwiftUI

struct GamePicker: View {
    @Environment(\.undoManager) var undoManager
    @ObservedObject var document: HolyokeDocument
    
    @State private var isPresentingDeleteConfirmation = false
    
    var body: some View {
        VStack {
            Text("**Games**")
            Picker("Game", selection: $document.currentGameIndex) {
                ForEach(document.games.indices, id: \.self) { index in
                    Text(document.games[index].gameTitleDescription).tag(index)
                }
            }
            
            HStack {

                Button("Delete") {
                    isPresentingDeleteConfirmation = true
                }
                .keyboardShortcut(.delete, modifiers: .command)
                .help("Delete game")
                .confirmationDialog("Delete game?", isPresented: $isPresentingDeleteConfirmation) {
                    Button("Confirm Delete", role: .destructive) {
                        document.deleteCurrentGame()
                    }
                }
                
                Spacer()
                
                Button("New Game") {
                    document.createNewGame(undoManager: undoManager)
                }
            }
        }
    }
}

struct GamePicker_Previews: PreviewProvider {
    static var previews: some View {
        GamePicker(document: HolyokeDocument())
    }
}
