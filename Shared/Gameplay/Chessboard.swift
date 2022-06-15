//
//  Chessboard.swift
//  Holyoke (iOS)
//
//  Created by Brian Yu on 6/11/22.
//

import Foundation

// Board position
// Chessboard is represented by an 8x8 2D array
// Each row represents a rank, starting with the 8th rank
typealias ChessPosition = [[Piece?]]

struct Chessboard : CustomStringConvertible {
    private var position : ChessPosition
    private var mostRecentMove : Move?
    
    private var whiteRightToCastleKingside = true
    private var whiteRightToCastleQueenside = true
    private var blackRightToCastleKingside = true
    private var blackRightToCastleQueenside = true
    
    // Starts at 1 on the first turn, increments after each Black turn
    private var fullmoveNumber : Int
    
    // Starts at 0, increases by 1 for every non-capture, non-pawn move
    private var halfmoveClock : Int

    // Returns an empty chess position
    static func emptyPosition() -> ChessPosition {
        return [[Piece?]](repeating: [Piece?](repeating: nil, count: 8), count: 8)
    }
    
    init(position: ChessPosition, mostRecentMove: Move?, fullmoveNumber: Int, halfmoveClock: Int) {
        self.position = position
        self.mostRecentMove = mostRecentMove
        self.fullmoveNumber = fullmoveNumber
        self.halfmoveClock = halfmoveClock
    }
    
    // Initialize in starting position
    init() {
        position = [
            [
                Piece(color: .black, type: .rook),
                Piece(color: .black, type: .knight),
                Piece(color: .black, type: .bishop),
                Piece(color: .black, type: .queen),
                Piece(color: .black, type: .king),
                Piece(color: .black, type: .bishop),
                Piece(color: .black, type: .knight),
                Piece(color: .black, type: .rook),
            ],
            [
                Piece(color: .black, type: .pawn),
                Piece(color: .black, type: .pawn),
                Piece(color: .black, type: .pawn),
                Piece(color: .black, type: .pawn),
                Piece(color: .black, type: .pawn),
                Piece(color: .black, type: .pawn),
                Piece(color: .black, type: .pawn),
                Piece(color: .black, type: .pawn),
            ],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [
                Piece(color: .white, type: .pawn),
                Piece(color: .white, type: .pawn),
                Piece(color: .white, type: .pawn),
                Piece(color: .white, type: .pawn),
                Piece(color: .white, type: .pawn),
                Piece(color: .white, type: .pawn),
                Piece(color: .white, type: .pawn),
                Piece(color: .white, type: .pawn),
            ],
            [
                Piece(color: .white, type: .rook),
                Piece(color: .white, type: .knight),
                Piece(color: .white, type: .bishop),
                Piece(color: .white, type: .queen),
                Piece(color: .white, type: .king),
                Piece(color: .white, type: .bishop),
                Piece(color: .white, type: .knight),
                Piece(color: .white, type: .knight),
                Piece(color: .white, type: .rook),
            ]
        ]
        mostRecentMove = nil
        fullmoveNumber = 1
        halfmoveClock = 0
    }
    
    var description : String {
        var representation = ""
        for rank in position {
            for square in rank {
                if let square = square {
                    representation += square.description
                } else {
                    representation += "_"
                }
            }
            representation += "\n"
        }
        return representation
    }
}
