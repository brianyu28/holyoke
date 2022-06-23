//
//  GameMetadataView.swift
//  Holyoke
//
//  Created by Brian Yu on 6/19/22.
//

import SwiftUI

struct GameMetadataView: View {
    var body: some View {
        return VStack(alignment: .leading) {
            GamePicker()
            Divider()
            GameMetadataEditor()
            Divider()
            GameStartPositionEditor()
        }
        .padding()
    }
}

struct GameMetadataView_Previews: PreviewProvider {
    static var previews: some View {
        GameMetadataView()
    }
}
