//
//  GameTreeView.swift
//  Holyoke
//
// View for
//
//  Created by Brian Yu on 6/17/22.
//

import SwiftUI

struct GameTreeView: View {
    
    @ObservedObject var document: HolyokeDocument
    
    var body: some View {
        Text("Game Tree View")
    }
}

struct GameTreeView_Previews: PreviewProvider {
    static var previews: some View {
        GameTreeView(document: HolyokeDocument())
    }
}
