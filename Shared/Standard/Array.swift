//
//  Array.swift
//  Holyoke
//
//  Created by Brian Yu on 6/20/22.
//

import Foundation

extension Array where Element: Equatable {
    
    /**
     Return all indices of array that match a given element.
     
     - Parameters:
        - value: The element in the array to search for.
     
     - Returns: A list of all indexes that match the value.
     */
    func allIndices(of value: Element) -> [Index] {
        // https://forums.swift.org/t/all-indexes-of-repeating-elements-in-array/41091
        indices.filter { self[$0] == value }
    }
    
}
