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
    @EnvironmentObject var state: DocumentState
    
    /**
     Size on pixels of a tree node.
     */
    static let nodeSize: CGFloat = 12.0
    
    /**
     Pixels between the center of any two nodes.
     */
    static let nodeSpacing: CGFloat = 18.0
    
    /**
     Given a node's row and column, return its location.
     
     - Parameters:
        - rowIndex: The row index of the node.
        - colIndex: The column index of the node.
     
     - Returns: A `CGPoint` representing the location of the node.
     */
    static func nodeLocation(rowIndex: Int, colIndex: Int) -> CGSize {
        return CGSize(
            width: CGFloat(colIndex + 1) * Self.nodeSpacing,
            height: CGFloat(rowIndex + 1) * Self.nodeSpacing
        )
    }
    
    /**
     Given a node and a subsequent variation in the following column, return the path that connect the two.
     The column index of the child node need not be specified, since it's always the column following the parent node.
     
     - Parameters:
        - startRowIndex: The row index of the parent node.
        - endRowIndex: The row index of the child node.
        - startColIndex: The column index of the parent node.
        
     - Returns: Three `CGPoint` values representing the start, midpoint, and end of the path.
     */
    static func nodePath(startRowIndex: Int, endRowIndex: Int, startColIndex: Int) -> Path {
        let start = CGPoint(
            x: CGFloat(startColIndex + 1) * Self.nodeSpacing + (Self.nodeSize / 2),
            y: CGFloat(startRowIndex + 1) * Self.nodeSpacing + (Self.nodeSize / 2)
        )
        let end = CGPoint(
            x: CGFloat(startColIndex + 2) * Self.nodeSpacing + (Self.nodeSize / 2),
            y: CGFloat(endRowIndex + 1) * Self.nodeSpacing + (Self.nodeSize / 2)
        )
        
        if startRowIndex == endRowIndex {
            // If the points are on the same row, draw a single line
            return Path { path in
                path.move(to: start)
                path.addLine(to: end)
            }
        } else {
            // If the points are on different rows, draw the path as two lines
            let midpoint = CGPoint(
                x: CGFloat(startColIndex + 1) * Self.nodeSpacing + (Self.nodeSize / 2),
                y: CGFloat(endRowIndex + 1) * Self.nodeSpacing + (Self.nodeSize / 2)
            )
            
            return Path { path in
                path.move(to: start)
                path.addLine(to: midpoint)
                path.addLine(to: end)
            }
        }
    }
    
    /**
     Compute the width of the entire tree layout.
     
     - Parameters:
        - layout: Game layout.
     
     - Returns: The width of the tree layout.
     */
    static func layoutWidth(layout: [[PGNGameNode?]]) -> CGFloat {
        let maxRowLength: Int = (layout.map { $0.count }).max() ?? 0
        return CGFloat(maxRowLength + 2) * Self.nodeSpacing
    }
    
    /**
     Compute the height of the entire tree layout.
     
     - Parameters:
        - layout: Game layout.
     
     - Returns: The height of the tree layout.
     */
    static func layoutHeight(layout: [[PGNGameNode?]]) -> CGFloat {
        return CGFloat(layout.count + 2) * Self.nodeSpacing
    }
    
    // layout: 2D array of (row, col) for where PGNGameNodes are laid out
    // locations: Mapping from PGNGameNode ID -> row index in the final game layout
    let tree: (layout: [[PGNGameNode?]], locations: [Int: Int])
    
    var body: some View {
        ScrollViewReader { reader in
            ScrollView([.horizontal, .vertical]) {
                
                ZStack {
                    
                    // Draw lines
                    ForEach(tree.layout.indices, id:\.self) { (rowIndex: Int) in
                        ForEach(tree.layout[rowIndex].indices, id: \.self) { (colIndex: Int) in
                            if let node: PGNGameNode = tree.layout[rowIndex][colIndex] {
                                ForEach(node.variations) { (variation: PGNGameNode) in
                                    if let variationRow = tree.locations[variation.id] {
                                        Self.nodePath(startRowIndex: rowIndex, endRowIndex: variationRow, startColIndex: colIndex)
                                            .stroke(.black, lineWidth: 1)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Draw nodes
                    ForEach(0...(tree.layout.count - 1), id:\.self) { (rowIndex: Int) in
                        ForEach(0...(tree.layout[rowIndex].count - 1), id: \.self) { (colIndex: Int) in
                            if let node: PGNGameNode = tree.layout[rowIndex][colIndex] {
                                Circle()
                                    .size(width: Self.nodeSize, height: Self.nodeSize)
                                    .foregroundColor(node == state.currentNode ? .blue : .black)
                                    .offset(Self.nodeLocation(rowIndex: rowIndex, colIndex: colIndex))
                                    .onTapGesture {
                                        state.currentNode = node
                                    }
                                    .id(node.id)
                            }
                        }
                    }
                }
                .frame(
                    width: Self.layoutWidth(layout: tree.layout),
                    height: Self.layoutHeight(layout: tree.layout)
                )
                
            }
            .onReceive(state.$currentNode) { node in
//                reader.scrollTo(node.id, anchor: .center)
            }
        }
    }
}

struct GameTreeView_Previews: PreviewProvider {
    static var previews: some View {
        GameTreeView(tree: (layout: [], locations: [:]))
    }
}
