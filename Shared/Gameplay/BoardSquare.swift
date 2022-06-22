//
//  BoardSquare.swift
//  Holyoke
//
//  Created by Brian Yu on 6/22/22.
//

import Foundation

/**
 Represents a chess move as (rank, file), each in [0, 7].
 */
struct BoardSquare: CustomStringConvertible, Equatable, Hashable {
    let rank: BoardRank
    let file: Int
    
    static let fileMapping = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e", 5: "f", 6: "g", 7: "h"]
    static let fileReverseMapping = ["a": 0, "b": 1, "c": 2, "d": 3, "e": 4, "f": 5, "g": 6, "h": 7]
    
    init(rank: Int, file: Int) {
        self.rank = rank
        self.file = file
    }
    
    // Init from algebraic notation
    static func initFromSan(san: String) -> BoardSquare? {
        if san.count != 2 {
            return nil
        }
        let fileString: String = String(san[san.index(san.startIndex, offsetBy: 0)])
        let rank: Int? = Int(String(san[san.index(san.startIndex, offsetBy: 1)]))
        guard let rank = rank else {
            return nil
        }
        if rank < 0 || rank > 7 {
            return nil
        }
        let file: Int? = Self.fileReverseMapping[fileString] ?? nil
        guard let file = file else {
            return nil
        }
        if file < 0 || file > 7 {
            return nil
        }
        return BoardSquare(rank: rank, file: file)
    }
    
    public static func == (lhs: BoardSquare, rhs: BoardSquare) -> Bool {
        return lhs.rank == rhs.rank && lhs.file == rhs.file
    }
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(rank)
            hasher.combine(file)
    }
    
    var fileNotation: String {
        return Self.fileMapping[self.file] ?? "?"
    }
    
    var rankNotation: String {
        return "\(8 - self.rank)"
    }
    
    var notation: String {
        return "\(fileNotation)\(rankNotation)"
    }
    
    var description: String {
        return self.notation
    }
    
    var isValidSquare: Bool {
        return self.rank >= 0 && self.rank <= 7 && self.file >= 0 && self.file <= 7
    }
}
