//
//  Array.swift
//  Holyoke
//
//  Created by Brian Yu on 6/20/22.
//

import Foundation

// https://forums.swift.org/t/all-indexes-of-repeating-elements-in-array/41091
extension Array where Element: Equatable {
    func allIndices(of value: Element) -> [Index] {
        indices.filter { self[$0] == value }
    }
}
