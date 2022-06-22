//
//  BoardRank.swift
//  Holyoke
//
//  Created by Brian Yu on 6/22/22.
//

import Foundation

/**
 Represents the rank of a square of a chessboard as a value in `[0, 7]`.
 0 represents the 8th rank, 7 represents the 1st rank.
 */
typealias BoardRank = Int

extension BoardRank {
    
    /**
     Whether the rank is a valid rank on the chessboard.
     */
    var isValidRank: Bool {
        return (0...7).contains(self)
    }

}
