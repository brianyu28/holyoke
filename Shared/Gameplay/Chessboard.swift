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

class Chessboard : CustomStringConvertible {
    var position: ChessPosition
    var mostRecentMove: Move?
    
    // Properties computed on each move
    var whiteRightToCastleKingside: Bool = true
    var whiteRightToCastleQueenside: Bool = true
    var blackRightToCastleKingside: Bool = true
    var blackRightToCastleQueenside: Bool = true
    
    // Starts at 1 on the first turn, increments after each Black turn
    private var fullmoveNumber: Int
    
    // Starts at 0, increases by 1 for every non-capture, non-pawn move
    private var halfmoveClock: Int
    
    var legalMoves: [Move]
    
    // Rank and file directions
    static private let diagionalDirections = [(1, 1), (1, -1), (-1, 1), (-1, -1)]
    static private let horizontalDirections = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    
    /**
     * Returns the piece at given coordinates.
     */
    func pieceAt(rank: Int, file: Int) -> Piece? {
        if ((0...7).contains(rank) && (0...7).contains(file)) {
            return position[rank][file]
        }
        return nil
    }
    
    /**
     Returns all of the pieces.
     */
    func piecesForPlayer(player: PlayerColor) -> [(Piece, BoardSquare)] {
        var pieces: [(Piece, BoardSquare)] = []
        for rankIndex in 0...7 {
            for fileIndex in 0...7 {
                if let piece = position[rankIndex][fileIndex] {
                    if piece.color == player {
                        pieces.append((piece, BoardSquare(rank: rankIndex, file: fileIndex)))
                    }
                }
            }
        }
        return pieces
    }

    // Returns an empty chess position
    static func emptyPosition() -> ChessPosition {
        return [[Piece?]](repeating: [Piece?](repeating: nil, count: 8), count: 8)
    }
    
    init(position: ChessPosition, mostRecentMove: Move?, fullmoveNumber: Int, halfmoveClock: Int, computeLegalMoves: Bool = true) {
        self.position = position
        self.mostRecentMove = mostRecentMove
        self.fullmoveNumber = fullmoveNumber
        self.halfmoveClock = halfmoveClock
        self.legalMoves = []
        if (computeLegalMoves) {
            self.computeAndSaveLegalMoves()
        } else {
            self.legalMoves = []
        }
    }
    
    // Initialize in starting position
    static func initInStartingPosition() -> Chessboard {
        let startingPosition = [
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
                Piece(color: .white, type: .rook),
            ]
        ]
        return Chessboard(position: startingPosition, mostRecentMove: nil, fullmoveNumber: 1, halfmoveClock: 0)
    }
    
    func getChessboardAfterMove(move: Move, computeNextLegalMoves: Bool = true) -> Chessboard {
        // TODO: This function does not yet take into consideration
        // - Castling
        
        guard let piece = self.pieceAt(rank: move.currentSquare.rank, file: move.currentSquare.file) else {
            return self
        }
        
        var newPosition = Self.emptyPosition()
        for rank in 0...7 {
            for file in 0...7 {
                newPosition[rank][file] = self.position[rank][file]
            }
        }
        
        // Make move
        newPosition[move.currentSquare.rank][move.currentSquare.file] = nil
        newPosition[move.newSquare.rank][move.newSquare.file] = piece
        
        // Check for en passant
        if move.isEnPassant {
            newPosition[piece.color == .white ? move.newSquare.rank + 1 : move.newSquare.rank - 1][move.newSquare.file] = nil
        }
        
        if let promotionPieceType = move.promotion {
            newPosition[move.newSquare.rank][move.newSquare.file] = Piece(color: piece.color, type: promotionPieceType)
        }
        
        return Chessboard(
            position: newPosition,
            mostRecentMove: move,
            fullmoveNumber: piece.color == .white ? self.fullmoveNumber : self.fullmoveNumber + 1,
            halfmoveClock: piece.type != .pawn && !move.isCapture ? self.halfmoveClock + 1 : 0,
            computeLegalMoves: computeNextLegalMoves
        )
    }
    
    // Checks if it is valid for a player to move a piece to a particular square
    // True if the square valid and either is empty or is occupied by the opposite player
    func isValidMovementSquare(square: BoardSquare, player: PlayerColor) -> (isValid: Bool, isCapture: Bool, wouldBeKingCapture: Bool) {
        if !square.isValidSquare {
            return (isValid: false, isCapture: false, wouldBeKingCapture: false)
        }
        let piece = self.pieceAt(rank: square.rank, file: square.file)
        if piece == nil {
            return (isValid: true, isCapture: false, wouldBeKingCapture: false)
        } else if piece!.color == player.nextColor {
            if piece!.type == .king {
                return (isValid: false, isCapture: false, wouldBeKingCapture: true)
            } else {
                return (isValid: true, isCapture: true, wouldBeKingCapture: false)
            }
        } else {
            return (isValid: false, isCapture: false, wouldBeKingCapture: false)
        }
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
    
    func computeAndSaveLegalMoves() {
        self.legalMoves = []
        self.legalMoves = self.computeLegalMoves()
    }
    
    func isPlayerInCheck(player: PlayerColor) -> Bool {
        
        var kingRank: Int? = nil
        var kingFile: Int? = nil
        
        // Find the king
        for rank in 0...7 {
            for file in 0...7 {
                if let piece = self.pieceAt(rank: rank, file: file) {
                    if piece.type == .king && piece.color == player {
                        kingRank = rank
                        kingFile = file
                    }
                }
            }
        }
        
        // Ensure the king is actually on the board
        guard let kingRank = kingRank, let kingFile = kingFile else {
            return true
        }
        
        for (rankDirection, fileDirection) in Self.horizontalDirections {
            var candidateSquare = BoardSquare(rank: kingRank + rankDirection, file: kingFile + fileDirection)
            while (true) {
                if !candidateSquare.isValidSquare {
                    break
                }
                let piece = self.pieceAt(rank: candidateSquare.rank, file: candidateSquare.file)
                if piece != nil && piece!.color == player.nextColor && (piece!.type == .rook || piece!.type == .queen) {
                    return true
                } else if piece != nil {
                    break
                }
                candidateSquare = BoardSquare(rank: candidateSquare.rank + rankDirection, file: candidateSquare.file + fileDirection)
            }
        }
        
        for (rankDirection, fileDirection) in Self.diagionalDirections {
            var candidateSquare = BoardSquare(rank: kingRank + rankDirection, file: kingFile + fileDirection)
            while (true) {
                if !candidateSquare.isValidSquare {
                    break
                }
                let piece = self.pieceAt(rank: candidateSquare.rank, file: candidateSquare.file)
                if piece != nil && piece!.color == player.nextColor && (piece!.type == .bishop || piece!.type == .queen) {
                    return true
                } else if piece != nil {
                    break
                }
                candidateSquare = BoardSquare(rank: candidateSquare.rank + rankDirection, file: candidateSquare.file + fileDirection)
            }
        }
        
        for (rankDirection, fileDirection) in Self.diagionalDirections {
            let candidateSquares = [
                BoardSquare(rank: kingRank + rankDirection * 2, file: kingFile + fileDirection * 1),
                BoardSquare(rank: kingRank + rankDirection * 1, file: kingFile + fileDirection * 2),
            ]
            for candidateSquare in candidateSquares {
                if let piece = self.pieceAt(rank: candidateSquare.rank, file: candidateSquare.file) {
                    if piece.color == player.nextColor && piece.type == .knight {
                        return true
                    }
                }
            }
        }
        
        let candidateSquares = [
            BoardSquare(rank: player == .white ? kingRank - 1 : kingRank + 1, file: kingFile - 1),
            BoardSquare(rank: player == .white ? kingRank - 1 : kingRank + 1, file: kingFile + 1),
        ]
        for candidateSquare in candidateSquares {
            if let piece = self.pieceAt(rank: candidateSquare.rank, file: candidateSquare.file) {
                if piece.color == player.nextColor && piece.type == .pawn {
                    return true
                }
            }
        }
        
        return false
    }
    
    func computeLegalMoves() -> [Move] {
        // TODO: This function does not yet take into consideration
        // - Castling
        
        // Reset legal moves to be empty array
        var moves: [Move] = []
        
        let playerToMove = mostRecentMove?.piece.color.nextColor ?? .white
        let playerPieces = self.piecesForPlayer(player: playerToMove)
        
        // Check for all possible moves
        for (piece, currentSquare) in playerPieces {
            switch (piece.type) {
            case .pawn:
                
                let nextRank = playerToMove == .white ? currentSquare.rank - 1 : currentSquare.rank + 1
                
                // Allow pawns to move one square forward
                let nextSquare = BoardSquare(rank: nextRank, file: currentSquare.file)
                let squareInfo = self.isValidMovementSquare(square: nextSquare, player: playerToMove)
                if squareInfo.isValid && !squareInfo.isCapture {
                    
                    if nextRank == (playerToMove == .white ? 0 : 7) {
                        // Promotion
                        for pieceType in [PieceType.queen, PieceType.rook, PieceType.knight, PieceType.bishop] {
                            moves.append(Move(withPawnPromoting: piece, toPiece: pieceType, currentSquare: currentSquare, newSquare: nextSquare, isCapture: false))
                        }
                    } else {
                        // Non-promotion
                        moves.append(Move(piece: piece, currentSquare: currentSquare, newSquare: nextSquare, isCapture: false))
                        
                        // Allow pawns to move two squares forward on the first move
                        if currentSquare.rank == (playerToMove == .white ? 6 : 1) {
                            let twoSquaresAhead = BoardSquare(rank: playerToMove == .white ? currentSquare.rank - 2 : currentSquare.rank + 2, file: currentSquare.file)
                            let twoSquareInfo = self.isValidMovementSquare(square: twoSquaresAhead, player: playerToMove)
                            if twoSquareInfo.isValid && !twoSquareInfo.isCapture {
                                moves.append(Move(piece: piece, currentSquare: currentSquare, newSquare: twoSquaresAhead, isCapture: false))
                            }
                        }
                    }
                }
                
                // Pawns can capture diagonally
                let capturingSquares = [
                    BoardSquare(rank: nextRank, file: currentSquare.file - 1),
                    BoardSquare(rank: nextRank, file: currentSquare.file + 1)
                ]
                for capturingSquare in capturingSquares {
                    let squareInfo = self.isValidMovementSquare(square: capturingSquare, player: playerToMove)
                    if squareInfo.isValid && squareInfo.isCapture {
                        if nextRank == (playerToMove == .white ? 0 : 7) {
                            // Promotion
                            for pieceType in [PieceType.queen, PieceType.rook, PieceType.knight, PieceType.bishop] {
                                moves.append(Move(withPawnPromoting: piece, toPiece: pieceType, currentSquare: currentSquare, newSquare: capturingSquare, isCapture: true))
                            }
                        } else {
                            // Non-Promotion
                            moves.append(Move(piece: piece, currentSquare: currentSquare, newSquare: capturingSquare, isCapture: true))
                        }
                    }
                }
                
                // Check if En Passant is allowed
                if (currentSquare.rank == (playerToMove == .white ? 3 : 4) && self.mostRecentMove != nil && self.mostRecentMove!.piece.type == .pawn
                    && self.mostRecentMove!.newSquare.rank == (playerToMove == .white ? 3 : 4) && abs(self.mostRecentMove!.newSquare.file - currentSquare.file) == 1) {
                    moves.append(Move(withEnPassantByPawn: piece, currentSquare: currentSquare, newSquare: BoardSquare(rank: playerToMove == .white ? 2 : 5, file: self.mostRecentMove!.newSquare.file)))
                }
                
            case .knight:
                
                for (rankDirection, fileDirection) in Self.diagionalDirections {
                    let possibleSquares = [
                        BoardSquare(rank: currentSquare.rank + rankDirection * 2, file: currentSquare.file + fileDirection * 1),
                        BoardSquare(rank: currentSquare.rank + rankDirection * 1, file: currentSquare.file + fileDirection * 2),
                    ]
                    for possibleSquare in possibleSquares {
                        let squareInfo = self.isValidMovementSquare(square: possibleSquare, player: playerToMove)
                        if squareInfo.isValid {
                            moves.append(Move(piece: piece, currentSquare: currentSquare, newSquare: possibleSquare, isCapture: squareInfo.isCapture))
                        }
                    }
                }

            case .bishop:
                
                for (rankDirection, fileDirection) in Self.diagionalDirections {
                    var candidateSquare = BoardSquare(rank: currentSquare.rank + rankDirection, file: currentSquare.file + fileDirection)
                    while (true) {
                        let squareInfo = self.isValidMovementSquare(square: candidateSquare, player: playerToMove)
                        if squareInfo.isValid {
                            moves.append(Move(piece: piece, currentSquare: currentSquare, newSquare: candidateSquare, isCapture: squareInfo.isCapture))
                            if squareInfo.isCapture {
                                break
                            }
                            candidateSquare = BoardSquare(rank: candidateSquare.rank + rankDirection, file: candidateSquare.file + fileDirection)
                        } else {
                            break
                        }
                    }
                }

            case .rook:
                
                for (rankDirection, fileDirection) in Self.horizontalDirections {
                    var candidateSquare = BoardSquare(rank: currentSquare.rank + rankDirection, file: currentSquare.file + fileDirection)
                    while (true) {
                        let squareInfo = self.isValidMovementSquare(square: candidateSquare, player: playerToMove)
                        if squareInfo.isValid {
                            moves.append(Move(piece: piece, currentSquare: currentSquare, newSquare: candidateSquare, isCapture: squareInfo.isCapture))
                            if squareInfo.isCapture {
                                break
                            }
                            candidateSquare = BoardSquare(rank: candidateSquare.rank + rankDirection, file: candidateSquare.file + fileDirection)
                        } else {
                            break
                        }
                    }
                }
                
            case .queen:
                
                for (rankDirection, fileDirection) in Self.horizontalDirections + Self.diagionalDirections {
                    var candidateSquare = BoardSquare(rank: currentSquare.rank + rankDirection, file: currentSquare.file + fileDirection)
                    while (true) {
                        let squareInfo = self.isValidMovementSquare(square: candidateSquare, player: playerToMove)
                        if squareInfo.isValid {
                            moves.append(Move(piece: piece, currentSquare: currentSquare, newSquare: candidateSquare, isCapture: squareInfo.isCapture))
                            if squareInfo.isCapture {
                                break
                            }
                            candidateSquare = BoardSquare(rank: candidateSquare.rank + rankDirection, file: candidateSquare.file + fileDirection)
                        } else {
                            break
                        }
                    }
                }
                
            case .king:
                
                for (rankDirection, fileDirection) in Self.horizontalDirections + Self.diagionalDirections {
                    let candidateSquare = BoardSquare(rank: currentSquare.rank + rankDirection, file: currentSquare.file + fileDirection)
                    let squareInfo = self.isValidMovementSquare(square: candidateSquare, player: playerToMove)
                    if squareInfo.isValid {
                        moves.append(Move(piece: piece, currentSquare: currentSquare, newSquare: candidateSquare, isCapture: squareInfo.isCapture))
                    }
                }
            }
        }
        
        return moves.filter { move in
            let tmpBoard = self.getChessboardAfterMove(move: move, computeNextLegalMoves: false)
            return !tmpBoard.isPlayerInCheck(player: move.piece.color)
        }
    }
}
