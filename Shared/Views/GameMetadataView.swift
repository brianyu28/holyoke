//
//  GameMetadataView.swift
//  Holyoke
//
//  Created by Brian Yu on 6/19/22.
//

import SwiftUI

struct GameMetadataView: View {
    @Environment(\.undoManager) var undoManager
    
    @ObservedObject var document: HolyokeDocument
    
    @State private var isPresentingDeleteConfirmation = false
    
    var body: some View {
        
        let whiteBinding = Binding<String>(get: {
            document.currentGame.getMetadata(query: "White") ?? "White"
        }, set: {
            document.currentGame.setMetadata(field: "White", value: $0)
            document.forceManualRefresh()
        })
        
        let blackBinding = Binding<String>(get: {
            document.currentGame.getMetadata(query: "Black") ?? "Black"
        }, set: {
            document.currentGame.setMetadata(field: "Black", value: $0)
            document.forceManualRefresh()
        })
        
        let eventBinding = Binding<String>(get: {
            document.currentGame.getMetadata(query: "Event") ?? "???"
        }, set: {
            document.currentGame.setMetadata(field: "Event", value: $0)
            document.forceManualRefresh()
        })
        
        let siteBinding = Binding<String>(get: {
            document.currentGame.getMetadata(query: "Site") ?? "???"
        }, set: {
            document.currentGame.setMetadata(field: "Site", value: $0)
            document.forceManualRefresh()
        })
        
        let dateBinding = Binding<String>(get: {
            document.currentGame.getMetadata(query: "Date") ?? "????.??.??"
        }, set: {
            document.currentGame.setMetadata(field: "Date", value: $0)
            document.forceManualRefresh()
        })
        
        let roundBinding = Binding<String>(get: {
            document.currentGame.getMetadata(query: "Round") ?? "?"
        }, set: {
            document.currentGame.setMetadata(field: "Round", value: $0)
            document.forceManualRefresh()
        })
        
        let resultBinding = Binding<PGNGameTermination>(get: {
            document.currentGame.gameTermination
        }, set: {
            document.currentGame.setMetadata(field: "Result", value: $0.rawValue)
            document.currentGame.gameTermination = $0
            document.forceManualRefresh()
        })
        
        return VStack(alignment: .leading) {
            
            Picker("Game", selection: $document.currentGameIndex) {
                ForEach(document.games.indices, id: \.self) { index in
                    Text(document.games[index].gameTitleDescription).tag(index)
                }
            }
            
            HStack {
                Text("White")
                Spacer()
                TextField("White", text: whiteBinding)
            }
            
            HStack {
                Text("Black")
                Spacer()
                TextField("Black", text: blackBinding)
            }
            
            HStack {
                Text("Date")
                Spacer()
                TextField("Date", text: dateBinding)
            }
            
            HStack {
                Text("Event")
                Spacer()
                TextField("Event", text: eventBinding)
            }
            
            HStack {
                Text("Site")
                Spacer()
                TextField("Site", text: siteBinding)
            }
            
            HStack {
                Text("Round")
                Spacer()
                TextField("Round", text: roundBinding)
            }
            
            Picker("Result", selection: resultBinding) {
                ForEach(PGNGameTermination.allCases, id: \.self) { result in
                    Text(result.rawValue)
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
        .padding()
    }
}

struct GameMetadataView_Previews: PreviewProvider {
    static var previews: some View {
        GameMetadataView(document: HolyokeDocument())
    }
}
