//
//  PGNGameTreeLayout.swift
//  Holyoke (macOS)
//
//  Created by Brian Yu on 6/22/22.
//

import Foundation

/**
 Location for where a PGNGameNode should be placed
 */
struct GameLayoutPoint: Hashable, Equatable {
    let row: Int
    let col: Int
    
    public static func == (lhs: GameLayoutPoint, rhs: GameLayoutPoint) -> Bool {
        return lhs.row == rhs.row && lhs.col == rhs.col
    }
}

/**
 Logic for handling node layout of a PGN Game.
 */
extension PGNGame {
    
    /**
     Lay out all nodes in the game on a 2D grid.
     
     - Returns: A pair `(layout, locations)`.
     `layout` is a 2D array representing a grid of where the nodes should appear in 2D space.
     `locations` is a mapping from node IDs to the row in which they should appear in the final layout.
     */
    func generateNodeLayout() -> (layout: [[PGNGameNode?]], locations: [Int: Int]) {
        
        // 2D array of (row, col) for where PGNGameNodes are laid out
        var layout: [[PGNGameNode?]] = []
        
        // Mapping from PGNGameNode ID -> row index in the final game layout
        var locations: [Int: Int] = [:]
        
        var avoid: Set<GameLayoutPoint> = []
        
        // Add node to layout with a minimum row, return its actual row
        func addNode(node: PGNGameNode, startingAtRowIndex startRow: Int) -> Int {
            let col: Int = node.moveNumber * 2 - (self.root.playerColor == node.playerColor ? 0 : 1)
            var row: Int = startRow
                
            while (true) {
                // Ensure that locations has enough rows
                while layout.count <= row {
                    layout.append([])
                }
                
                while layout[row].count <= col {
                    layout[row].append(nil)
                }
                
                if layout[row][col] == nil && !avoid.contains(GameLayoutPoint(row: row, col: col)) {
                    // There's space at the desired row
                    layout[row][col] = node
                    locations[node.id] = row
                    
                    // Avoid placing nodes between the parent and this node
                    if let parentRow = node.parent != nil ? locations[node.parent!.id] : nil {
                        if parentRow <= row {
                            for r in parentRow...row {
                                avoid.insert(GameLayoutPoint(row: r, col: col - 1))
                            }
                        }
                    }
                    
                    return row
                } else {
                    row += 1
                }
            }
        }
        
        func addVariation(node startNode: PGNGameNode, startingAtRowIndex startRow: Int) -> Int {
            
            // Keep track of nodes, so we can add variations later
            var nodes: [PGNGameNode] = []
            var currentRowIndex = startRow
            
            // What's the highest row index that was used
            var maxRowIndex = startRow
            
            // Loop through all of the moves, adding each where it fits
            var node: PGNGameNode? = startNode
            while (true) {
                guard let n = node else {
                    break
                }
                nodes.append(n)
                currentRowIndex = addNode(node: n, startingAtRowIndex: currentRowIndex)
                
                if n.variations.count == 0 {
                    break
                }
                node = n.variations[0]
            }
            
            // Go through and add variations
            for node in nodes.reversed() {
                var rowIndex: Int = locations[node.id] ?? 0
                for variation in node.variations.dropFirst() {
                    rowIndex = addVariation(node: variation, startingAtRowIndex: rowIndex + 1)
                    if rowIndex > maxRowIndex {
                        maxRowIndex = rowIndex
                    }
                }
            }
            
            return maxRowIndex
        }
        
        let _ = addVariation(node: self.root, startingAtRowIndex: 0)
        
        return (layout: layout, locations: locations)
    }
}
