//
//  GameMetadataEditor.swift
//  Holyoke
//
//  Created by Brian Yu on 6/21/22.
//

import SwiftUI

struct GameMetadataEditor: View {
    @EnvironmentObject var state: DocumentState
    
    var body: some View {
        
        let whiteBinding = Binding<String>(get: {
            state.currentGame.getMetadata(query: "White") ?? "White"
        }, set: {
            state.currentGame.setMetadata(field: "White", value: $0)
            state.forceManualRefresh()
        })
        
        let blackBinding = Binding<String>(get: {
            state.currentGame.getMetadata(query: "Black") ?? "Black"
        }, set: {
            state.currentGame.setMetadata(field: "Black", value: $0)
            state.forceManualRefresh()
        })
        
        let eventBinding = Binding<String>(get: {
            state.currentGame.getMetadata(query: "Event") ?? "???"
        }, set: {
            state.currentGame.setMetadata(field: "Event", value: $0)
            state.forceManualRefresh()
        })
        
        let siteBinding = Binding<String>(get: {
            state.currentGame.getMetadata(query: "Site") ?? "???"
        }, set: {
            state.currentGame.setMetadata(field: "Site", value: $0)
            state.forceManualRefresh()
        })
        
        let dateBinding = Binding<String>(get: {
            state.currentGame.getMetadata(query: "Date") ?? "????.??.??"
        }, set: {
            state.currentGame.setMetadata(field: "Date", value: $0)
            state.forceManualRefresh()
        })
        
        let roundBinding = Binding<String>(get: {
            state.currentGame.getMetadata(query: "Round") ?? "?"
        }, set: {
            state.currentGame.setMetadata(field: "Round", value: $0)
            state.forceManualRefresh()
        })
        
        let resultBinding = Binding<PGNGameTermination>(get: {
            state.currentGame.gameTermination
        }, set: {
            state.currentGame.setMetadata(field: "Result", value: $0.rawValue)
            state.currentGame.gameTermination = $0
            state.forceManualRefresh()
        })
        
        return VStack {
            Text("**Game Details**")
            
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
        }
    }
}

struct GameMetadataEditor_Previews: PreviewProvider {
    static var previews: some View {
        GameMetadataEditor()
    }
}
