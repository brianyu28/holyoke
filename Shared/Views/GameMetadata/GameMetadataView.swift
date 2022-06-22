//
//  GameMetadataView.swift
//  Holyoke
//
//  Created by Brian Yu on 6/19/22.
//

import SwiftUI

struct GameMetadataView: View {
    @ObservedObject var document: HolyokeDocument
    
    var body: some View {
        return VStack(alignment: .leading) {
            GamePicker(document: document)
            Divider()
            GameMetadataEditor(document: document)
            Divider()
            GameStartPositionEditor(document: document)
        }
        .padding()
    }
}

struct GameMetadataView_Previews: PreviewProvider {
    static var previews: some View {
        GameMetadataView(document: HolyokeDocument())
    }
}
