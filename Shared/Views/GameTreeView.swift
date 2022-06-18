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
    
    // layout: 2D array of (row, col) for where PGNGameNodes are laid out
    // locations: Mapping from PGNGameNode ID -> row index in the final game layout
    let tree: (layout: [[PGNGameNode?]], locations: [Int: Int])
    
    var body: some View {
        ZStack {
            ForEach(0...(tree.layout.count - 1), id:\.self) { rowIndex in
                ForEach(0...(tree.layout[rowIndex].count - 1), id: \.self) { colIndex in
                    if let node = tree.layout[rowIndex][colIndex] {
                        Circle()
                            .size(width: 10, height: 10)
                            .foregroundColor(node == document.currentNode ? .blue : .black)
                            .offset(x: CGFloat(colIndex) * 15.0, y: CGFloat(rowIndex) * 15.0)
                    }
                }
            }
        }
    }
}

struct GameTreeView_Previews: PreviewProvider {
    static var previews: some View {
        GameTreeView(document: HolyokeDocument(), tree: (layout: [], locations: [:]))
    }
}
