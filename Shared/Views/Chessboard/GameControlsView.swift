//
//  GameControlsView.swift
//  Holyoke
//
//  Created by Brian Yu on 6/17/22.
//

import SwiftUI

struct GameControlsView: View {
    @EnvironmentObject var state: DocumentState
    @Environment(\.undoManager) var undoManager
    
    @State private var isPresentingDeleteConfirmation = false
    
    var body: some View {
        HStack {
            Button {
                state.updateCurrentNodeToPreviousVariation()
            } label: {
                Image(systemName: "arrowtriangle.up")
            }
            .keyboardShortcut(.upArrow, modifiers: [])
            .help("Previous variation")
            
            Button {
                state.updateCurrentNodeToNextVariation()
            } label: {
                Image(systemName: "arrowtriangle.down")
            }
            .keyboardShortcut(.downArrow, modifiers: [])
            .help("Next variation")
            
            Button {
                isPresentingDeleteConfirmation = true
            } label: {
                Image(systemName: "trash")
            }
            .keyboardShortcut(.delete, modifiers: .command)
            .help("Delete variation")
            .confirmationDialog("Delete game node?", isPresented: $isPresentingDeleteConfirmation) {
                Button("Confirm Delete", role: .destructive) {
                    state.deleteCurrentNode()
                }
            }
            
            Spacer()
            
            Button {
                state.updateCurrentNodeToPreviousMove()
            } label: {
                Image(systemName: "arrow.left")
            }
            .keyboardShortcut(.leftArrow, modifiers: [])
            .help("Previous move")
            
            Button {
                state.updateCurrentNodeToNextMove()
            } label: {
                Image(systemName: "arrow.right")
            }
            .keyboardShortcut(.rightArrow, modifiers: [])
            .help("Next move")
        }
    }
}

struct GameControlsView_Previews: PreviewProvider {
    static var previews: some View {
        GameControlsView()
    }
}
