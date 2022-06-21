//
//  Collection.swift
//  Holyoke
//
//  Created by Brian Yu on 6/20/22.
//

import Foundation

extension Collection {

    subscript(optional i: Index) -> Iterator.Element? {
        return self.indices.contains(i) ? self[i] : nil
    }

}
