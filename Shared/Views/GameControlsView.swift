//
//  GameControlsView.swift
//  Holyoke
//
//  Created by Brian Yu on 6/17/22.
//

import SwiftUI

struct GameControlsView: View {
    @ObservedObject var document: HolyokeDocument
    
    @State private var isPresentingDeleteConfirmation = false
    
    @Environment(\.undoManager) var undoManager
    
    var body: some View {
        HStack {
            Button {
                document.updateCurrentNodeToPreviousVariation()
            } label: {
                Image(systemName: "arrowtriangle.up")
            }
            .keyboardShortcut(.upArrow, modifiers: [])
            .help("Previous variation")
            
            Button {
                document.updateCurrentNodeToNextVariation()
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
                    document.deleteCurrentNode()
                }
            }
            
            Spacer()
            
            Button {
                document.updateCurrentNodeToPreviousMove()
            } label: {
                Image(systemName: "arrow.left")
            }
            .keyboardShortcut(.leftArrow, modifiers: [])
            .help("Previous move")
            
            Button {
                document.updateCurrentNodeToNextMove()
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
        GameControlsView(document: HolyokeDocument())
    }
}
