//
//  Move.swift
//  Holyoke (iOS)
//
//  Created by Brian Yu on 6/11/22.
//

import Foundation

/**
 Represents color of player and color of piece.
 */
enum PlayerColor {
    case white
    case black
    
    var nextColor: PlayerColor {
        switch self {
        case .white:
            return .black
        case .black:
            return .white
        }
    }
}

/**
 Represents a chess piece.
 */
enum PieceType {
    case king
    case queen
    case rook
    case bishop
    case knight
    case pawn
    
    var description: String {
        switch self {
        case .king:
            return "K"
        case .queen:
            return "Q"
        case .rook:
            return "R"
        case .bishop:
            return "B"
        case .knight:
            return "N"
        case .pawn:
            return "P"
        }
    }
}

struct Piece : CustomStringConvertible {
    let color: PlayerColor
    let type: PieceType
    
    // Return piece description in FEN notation
    var description: String {
        let symbol: String = {
            switch type {
            case .king:
                return "K"
            case .queen:
                return "Q"
            case .rook:
                return "R"
            case .bishop:
                return "B"
            case .knight:
                return "N"
            case .pawn:
                return "P"
            }
        }()
        return color == .white ? symbol : symbol.lowercased()
    }
    
    // Returns assetname for piece
    var assetName: String {
        let pieceName: String = {
            switch type {
            case .king:
                return "King"
            case .queen:
                return "Queen"
            case .rook:
                return "Rook"
            case .bishop:
                return "Bishop"
            case .knight:
                return "Knight"
            case .pawn:
                return "Pawn"
            }
        }()
        let colorName: String = {
            switch color {
            case .white:
                return "White"
            case .black:
                return "Black"
            }
        }()
        return "ChessPiece_\(colorName)_\(pieceName)"
    }
}

/**
 Represents a chess move as (rank, file), each in [0, 7].
 */
struct BoardSquare: CustomStringConvertible, Equatable, Hashable {
    let rank: Int
    let file: Int
    
    static let fileMapping = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e", 5: "f", 6: "g", 7: "h"]
    static let fileReverseMapping = ["a": 0, "b": 1, "c": 2, "d": 3, "e": 4, "f": 5, "g": 6, "h": 7]
    
    init(rank: Int, file: Int) {
        self.rank = rank
        self.file = file
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

/**
 Represents a chess move.
 */
struct Move: Identifiable {
    let piece: Piece
    let currentSquare: BoardSquare
    let newSquare: BoardSquare
    let isCapture: Bool
    
    // Additional metadata for "special" moves.
    let isCastleShort: Bool
    let isCastleLong: Bool
    let isEnPassant: Bool
    let promotion: PieceType?
    
    var id: String {
        return "\(piece.description)\(currentSquare.notation)\(newSquare.notation)"
    }
    
    var longDescription: String {
        if self.isCastleShort {
            return "0-0"
        } else if self.isCastleLong {
            return "0-0-0"
        } else if let promotionType = self.promotion {
            return "\(piece.description) \(currentSquare.notation)-\(newSquare.notation)=\(promotionType.description)"
        } else {
            return "\(piece.description) \(currentSquare.notation)-\(newSquare.notation)"
        }
    }
    
    // Initializer for normal moves
    init(piece: Piece, currentSquare: BoardSquare, newSquare: BoardSquare, isCapture: Bool) {
        self.piece = piece
        self.currentSquare = currentSquare
        self.newSquare = newSquare
        self.isCapture = isCapture
        
        self.isCastleShort = false
        self.isCastleLong = false
        self.isEnPassant = false
        self.promotion = nil
    }
    
    init(withPieceCastlingShort piece: Piece) {
        if piece.type != .king {
            fatalError("Attempt to castle short with a non-king piece.")
        }
        self.piece = piece
        self.currentSquare = BoardSquare(rank: piece.color == .white ? 7 : 0, file: 4)
        self.newSquare = BoardSquare(rank: piece.color == .white ? 7 : 0, file: 6)
        self.isCapture = false
        
        self.isCastleShort = true
        self.isCastleLong = false
        self.isEnPassant = false
        self.promotion = nil
    }
    
    init(withPieceCastlingLong piece: Piece) {
        if piece.type != .king {
            fatalError("Attempt to castle short with a non-king piece.")
        }
        self.piece = piece
        self.currentSquare = BoardSquare(rank: piece.color == .white ? 7 : 0, file: 4)
        self.newSquare = BoardSquare(rank: piece.color == .white ? 7 : 0, file: 2)
        self.isCapture = false
        
        self.isCastleShort = false
        self.isCastleLong = true
        self.isEnPassant = false
        self.promotion = nil
    }
    
    init(withEnPassantByPawn piece: Piece, currentSquare: BoardSquare, newSquare: BoardSquare) {
        if piece.type != .pawn {
            fatalError("Attempt to en passant with a non-pawn piece.")
        }
        self.piece = piece
        self.currentSquare = currentSquare
        self.newSquare = newSquare
        self.isCapture = true
        
        self.isCastleShort = false
        self.isCastleLong = false
        self.isEnPassant = true
        self.promotion = nil
    }
    
    init(withPawnPromoting piece: Piece, toPiece newPiece: PieceType, currentSquare: BoardSquare, newSquare: BoardSquare, isCapture: Bool) {
        if piece.type != .pawn {
            fatalError("Attempted to promote a non-pawn piece.")
        }
        self.piece = piece
        self.currentSquare = currentSquare
        self.newSquare = newSquare
        self.isCapture = isCapture
        
        self.isCastleShort = false
        self.isCastleLong = false
        self.isEnPassant = false
        self.promotion = newPiece
    }
}
