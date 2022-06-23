//
//  GamePicker.swift
//  Holyoke
//
//  Created by Brian Yu on 6/21/22.
//

import SwiftUI

struct GamePicker: View {
    @EnvironmentObject var state: DocumentState
    @Environment(\.undoManager) var undoManager
    
    @State private var isPresentingDeleteConfirmation = false
    
    var body: some View {
        VStack {
            Text("**Games**")
            Picker("Game", selection: $state.currentGameIndex) {
                ForEach(state.document.games.indices, id: \.self) { index in
                    Text(state.document.games[index].gameTitleDescription).tag(index)
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
                        state.deleteCurrentGame()
                    }
                }
                
                Spacer()
                
                Button("New Game") {
                    state.createNewGame()
                }
            }
        }
    }
}

struct GamePicker_Previews: PreviewProvider {
    static var previews: some View {
        GamePicker()
    }
}
