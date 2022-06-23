//
//  GameMetadataView.swift
//  Holyoke
//
//  Created by Brian Yu on 6/19/22.
//

import SwiftUI

struct GameMetadataView: View {
    @EnvironmentObject var state: DocumentState
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                GamePicker()
                Divider()
                GameMetadataEditor()
                Divider()
                GameStartPositionEditor()
                Divider()
                Text(state.currentNode.moveSequenceUntilCurrentNode())
                    .textSelection(.enabled)
            }
            .padding()
        }
    }
}

struct GameMetadataView_Previews: PreviewProvider {
    static var previews: some View {
        GameMetadataView()
    }
}
