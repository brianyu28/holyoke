//
//  GameControlsView.swift
//  Holyoke
//
//  Created by Brian Yu on 6/17/22.
//

import SwiftUI

struct GameControlsView: View {
    @ObservedObject var document: HolyokeDocument
    
    var body: some View {
        HStack {
            
            Button {
                document.previousMove()
            } label: {
                Image(systemName: "arrow.left")
            }
            
            Button {
                document.nextMove()
            } label: {
                Image(systemName: "arrow.right")
            }
        }
    }
}

struct GameControlsView_Previews: PreviewProvider {
    static var previews: some View {
        GameControlsView(document: HolyokeDocument())
    }
}
