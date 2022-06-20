//
//  GameMetadataView.swift
//  Holyoke
//
//  Created by Brian Yu on 6/19/22.
//

import SwiftUI

struct GameMetadataView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var document: HolyokeDocument
    
    @State private var isPresentingDeleteConfirmation = false
    
    @State private var metaEvent = ""
    @State private var metaSite = ""
    @State private var metaDate = ""
    @State private var metaRound = ""
    @State private var metaWhite = ""
    @State private var metaBlack = ""
    @State private var metaResult: PGNGameTermination = .asterisk
    
    func setMetadataFieldsToGameData() {
        metaEvent = document.currentGame.getMetadata(query: "Event") ?? "???"
        metaSite = document.currentGame.getMetadata(query: "Site") ?? "???"
        metaDate = document.currentGame.getMetadata(query: "Date") ?? "????.??.??"
        metaRound = document.currentGame.getMetadata(query: "Round") ?? "?"
        metaWhite = document.currentGame.getMetadata(query: "White") ?? "White"
        metaBlack = document.currentGame.getMetadata(query: "Black") ?? "Black"
        metaResult = document.currentGame.gameTermination
    }
    
    func saveMetadataToGameData() {
        document.currentGame.setMetadata(field: "Event", value: metaEvent)
        document.currentGame.setMetadata(field: "Site", value: metaSite)
        document.currentGame.setMetadata(field: "Date", value: metaDate)
        document.currentGame.setMetadata(field: "Round", value: metaRound)
        document.currentGame.setMetadata(field: "White", value: metaWhite)
        document.currentGame.setMetadata(field: "Black", value: metaBlack)
        document.currentGame.setMetadata(field: "Result", value: metaResult.rawValue)
        document.currentGame.gameTermination = metaResult
        document.forceManualRefresh()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Picker("Game", selection: $document.currentGameIndex) {
                ForEach(document.games.indices, id: \.self) { index in
                    Text(document.games[index].gameTitleDescription).tag(index)
                }
                .onChange(of: document.currentGameIndex) { _ in
                    setMetadataFieldsToGameData()
                }
            }
            
            HStack {
                Text("White")
                Spacer()
                TextField("White", text: $metaWhite)
            }
            
            HStack {
                Text("Black")
                Spacer()
                TextField("Black", text: $metaBlack)
            }
            
            HStack {
                Text("Date")
                Spacer()
                TextField("Date", text: $metaDate)
            }
            
            HStack {
                Text("Event")
                Spacer()
                TextField("Event", text: $metaEvent)
            }
            
            HStack {
                Text("Site")
                Spacer()
                TextField("Site", text: $metaSite)
            }
            
            HStack {
                Text("Round")
                Spacer()
                TextField("Round", text: $metaRound)
            }
            
            Picker("Result", selection: $metaResult) {
                ForEach(PGNGameTermination.allCases, id: \.self) { result in
                    Text(result.rawValue)
                }
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
                
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
                
                Button("New Game") {
                    
                }
                
                Button("Save") {
                    saveMetadataToGameData()
                    dismiss()
                }
                .keyboardShortcut(.return, modifiers: .command)
            }
            
        }
        .padding()
        .onAppear {
            setMetadataFieldsToGameData()
        }
    }
}

struct GameMetadataView_Previews: PreviewProvider {
    static var previews: some View {
        GameMetadataView(document: HolyokeDocument())
    }
}
