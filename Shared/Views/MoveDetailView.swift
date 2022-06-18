//
//  MoveDetailView.swift
//  Holyoke
//
//  Created by Brian Yu on 6/17/22.
//

import SwiftUI

struct MoveDetailView: View {
    
    @ObservedObject var document: HolyokeDocument
    
    var body: some View {
        TextEditor(text: $document.currentNode.braceComment)
    }
}

struct MoveDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MoveDetailView(document: HolyokeDocument())
    }
}
