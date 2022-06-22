//
//  Collection.swift
//  Holyoke
//
//  Created by Brian Yu on 6/20/22.
//

import Foundation

/**
 Extension to `Collection` to allow optional subscripting.
 */
extension Collection {
    
    /**
     Allow subscripting a collection with `x[optional: y]`, which returns `nil` if index doesn't exist.
     
     - Returns: Element at the index if the index exists, `nil` if the index does not exist.
     */
    subscript(optional i: Index) -> Iterator.Element? {
        return self.indices.contains(i) ? self[i] : nil
    }

}
