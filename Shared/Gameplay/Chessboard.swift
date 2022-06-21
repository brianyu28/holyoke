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
    var whiteRightToCastleKingside: Bool
    var whiteRightToCastleQueenside: Bool
    var blackRightToCastleKingside: Bool
    var blackRightToCastleQueenside: Bool
    
    // Starts at 1 on the first turn, increments after each Black turn
    private var fullmoveNumber: Int
    
    // Starts at 0, increases by 1 for every non-capture, non-pawn move
    private var halfmoveClock: Int
    
    // Dictionary mapping move name in Algebraic Notation to move
    var legalMoves: [String: Move]
    
    // Rank and file directions
    static private let diagionalDirections = [(1, 1), (1, -1), (-1, 1), (-1, -1)]
    static private let horizontalDirections = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    
    var fen: String {
        var boardState = ""
        for (i, row) in self.position.enumerated() {
            var spaces = 0
            for piece in row {
                guard let piece = piece else {
                    spaces += 1
                    continue
                }
                if spaces > 0 {
                    boardState += String(spaces)
                    spaces = 0
                }
                boardState += piece.description
            }
            if spaces > 0 {
                boardState += String(spaces)
            }
            if i < 7 {
                boardState += "/"
            }
        }
        
        let activeColor = self.playerToMove == .white ? "w" : "b"
        
        var castling = ""
        if self.whiteRightToCastleKingside {
            castling += "K"
        }
        if self.whiteRightToCastleQueenside {
            castling += "Q"
        }
        if self.blackRightToCastleKingside {
            castling += "k"
        }
        if self.blackRightToCastleQueenside {
            castling += "q"
        }
        if castling.count == 0 {
            castling = "-"
        }
        
        var enPassant = "-"
        if let move = self.mostRecentMove {
            if move.piece.type == .pawn && move.piece.color == .white && move.currentSquare.rank == 6 && move.newSquare.rank == 4 {
                enPassant = "\(move.currentSquare.fileNotation)3"
            } else if move.piece.type == .pawn && move.piece.color == .black && move.currentSquare.rank == 1 && move.newSquare.rank == 3 {
                enPassant = "\(move.currentSquare.fileNotation)6"
            }
        }
        
        return "\(boardState) \(activeColor) \(castling) \(enPassant) \(halfmoveClock) \(fullmoveNumber)"
    }
    
    var playerToMove: PlayerColor {
        return mostRecentMove?.piece.color.nextColor ?? .white
    }
    
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
        self.legalMoves = [:]
        
        self.whiteRightToCastleKingside = true
        self.whiteRightToCastleQueenside = true
        self.blackRightToCastleKingside = true
        self.blackRightToCastleQueenside = true
        
        if (computeLegalMoves) {
            self.computeAndSaveLegalMoves()
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
        
        // Check for castling
        if move.isCastleShort {
            let rookRank = piece.color == .white ? 7 : 0
            let rookStartFile = 7
            let rookEndFile = 5
            newPosition[rookRank][rookEndFile] = newPosition[rookRank][rookStartFile]
            newPosition[rookRank][rookStartFile] = nil
        } else if move.isCastleLong {
            let rookRank = piece.color == .white ? 7 : 0
            let rookStartFile = 0
            let rookEndFile = 3
            newPosition[rookRank][rookEndFile] = newPosition[rookRank][rookStartFile]
            newPosition[rookRank][rookStartFile] = nil
        }
        
        let board = Chessboard(
            position: newPosition,
            mostRecentMove: move,
            fullmoveNumber: piece.color == .white ? self.fullmoveNumber : self.fullmoveNumber + 1,
            halfmoveClock: piece.type != .pawn && !move.isCapture ? self.halfmoveClock + 1 : 0,
            computeLegalMoves: false
        )
        board.whiteRightToCastleKingside = (
            self.whiteRightToCastleKingside &&
            !(move.piece.color == .white && move.piece.type == .king) &&
            !(move.piece.color == .white && move.piece.type == .rook && move.currentSquare.rank == 7 && move.currentSquare.file == 7)
        )
        board.whiteRightToCastleQueenside = (
            self.whiteRightToCastleQueenside &&
            !(move.piece.color == .white && move.piece.type == .king) &&
            !(move.piece.color == .white && move.piece.type == .rook && move.currentSquare.rank == 7 && move.currentSquare.file == 0)
        )
        board.blackRightToCastleKingside = (
            self.blackRightToCastleKingside &&
            !(move.piece.color == .black && move.piece.type == .king) &&
            !(move.piece.color == .black && move.piece.type == .rook && move.currentSquare.rank == 0 && move.currentSquare.file == 7)
        )
        board.blackRightToCastleQueenside = (
            self.blackRightToCastleQueenside &&
            !(move.piece.color == .black && move.piece.type == .king) &&
            !(move.piece.color == .black && move.piece.type == .rook && move.currentSquare.rank == 0 && move.currentSquare.file == 0)
        )
        
        if (computeNextLegalMoves) {
            board.computeAndSaveLegalMoves()
        }
        
        return board
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
        self.legalMoves = [:]
        
        let moveList = self.computeLegalMoves()
        for move in moveList {
            
            var suffix = ""
            let board = self.getChessboardAfterMove(move: move, computeNextLegalMoves: false)
            if board.isPlayerInCheck(player: board.playerToMove) {
                if board.isPlayerInCheckmate(player: board.playerToMove) {
                    suffix = "#"
                } else {
                    suffix = "+"
                }
            }
            if move.piece.type == .pawn {
                var moveName = ""
                if move.isCapture {
                    moveName += "\(move.currentSquare.fileNotation)x"
                }
                moveName += move.newSquare.notation
                if let promotionType = move.promotion {
                    moveName += "=\(promotionType.description)"
                }
                self.legalMoves[moveName + suffix] = move
            } else if move.isCastleShort {
                self.legalMoves["0-0" + suffix] = move
            } else if move.isCastleLong {
                self.legalMoves["0-0-0" + suffix] = move
            } else {
                let ambiguousMoves = moveList.filter { otherMove in
                    move.piece.type == otherMove.piece.type &&
                    move.newSquare.rank == otherMove.newSquare.rank &&
                    move.newSquare.file == otherMove.newSquare.file
                }
                
                var moveName = ""
                if ambiguousMoves.count == 1 {
                    moveName += move.piece.type.description
                } else if (ambiguousMoves.filter { otherMove in move.currentSquare.file == otherMove.currentSquare.file }).count == 1 {
                    moveName += move.piece.type.description + move.currentSquare.fileNotation
                } else if (ambiguousMoves.filter { otherMove in move.currentSquare.rank == otherMove.currentSquare.rank }).count == 1 {
                    moveName += move.piece.type.description + move.currentSquare.rankNotation
                } else {
                    moveName += move.piece.type.description + move.currentSquare.notation
                }
                if move.isCapture {
                    moveName += "x"
                }
                moveName += move.newSquare.notation
                self.legalMoves[moveName + suffix] = move
            }
        }
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
    
    func isPlayerInCheckmate(player: PlayerColor) -> Bool {
        // It must be the player's turn to be in checkmate
        if self.playerToMove != player {
            return false
        }
        
        // Player must be in check to be in checkmate
        if !self.isPlayerInCheck(player: player) {
            return false
        }
        
        // If player has existing legal moves, they're not in checkmate
        if !self.legalMoves.isEmpty {
            return false
        }
        
        // Otherwise, compute moves in case they weren't already computed
        self.computeAndSaveLegalMoves()
        return self.legalMoves.isEmpty
    }
    
    func computeLegalMoves() -> [Move] {
        
        // Reset legal moves to be empty array
        var moves: [Move] = []
        
        let playerToMove = self.playerToMove
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
                
                // Castling
                // Requirements:
                // - Cannot castle if currently in check
                // - King and rook cannot have previously moved
                // - No pieces in between king and rook
                // - King does not pass through check
                if !self.isPlayerInCheck(player: playerToMove) {
                    
                    if playerToMove == .white && self.whiteRightToCastleKingside {
                        
                        let betweenSquares = [BoardSquare(rank: 7, file: 5), BoardSquare(rank: 7, file: 6)]
                        let intermediateSquare = BoardSquare(rank: 7, file: 5)
                        if betweenSquares.allSatisfy( { square in self.pieceAt(rank: square.rank, file: square.file) == nil } ) {
                            if !self.getChessboardAfterMove(move: Move(piece: piece, currentSquare: currentSquare, newSquare: intermediateSquare, isCapture: false), computeNextLegalMoves: false).isPlayerInCheck(player: playerToMove) {
                                moves.append(Move(withPieceCastlingShort: piece))
                            }
                        }
                    }
                    if playerToMove == .white && self.whiteRightToCastleQueenside {
                        let betweenSquares = [BoardSquare(rank: 7, file: 1), BoardSquare(rank: 7, file: 2), BoardSquare(rank: 7, file: 3)]
                        let intermediateSquare = BoardSquare(rank: 7, file: 3)
                        if betweenSquares.allSatisfy( { square in self.pieceAt(rank: square.rank, file: square.file) == nil } ) {
                            if !self.getChessboardAfterMove(move: Move(piece: piece, currentSquare: currentSquare, newSquare: intermediateSquare, isCapture: false), computeNextLegalMoves: false).isPlayerInCheck(player: playerToMove) {
                                moves.append(Move(withPieceCastlingLong: piece))
                            }
                        }
                    }
                    if playerToMove == .black && self.blackRightToCastleKingside {
                        let betweenSquares = [BoardSquare(rank: 0, file: 5), BoardSquare(rank: 0, file: 6)]
                        let intermediateSquare = BoardSquare(rank: 0, file: 5)
                        if betweenSquares.allSatisfy( { square in self.pieceAt(rank: square.rank, file: square.file) == nil } ) {
                            if !self.getChessboardAfterMove(move: Move(piece: piece, currentSquare: currentSquare, newSquare: intermediateSquare, isCapture: false), computeNextLegalMoves: false).isPlayerInCheck(player: playerToMove) {
                                moves.append(Move(withPieceCastlingShort: piece))
                            }
                        }
                    }
                    if playerToMove == .black && self.blackRightToCastleQueenside {
                        let betweenSquares = [BoardSquare(rank: 0, file: 1), BoardSquare(rank: 0, file: 2), BoardSquare(rank: 0, file: 3)]
                        let intermediateSquare = BoardSquare(rank: 0, file: 3)
                        if betweenSquares.allSatisfy( { square in self.pieceAt(rank: square.rank, file: square.file) == nil } ) {
                            if !self.getChessboardAfterMove(move: Move(piece: piece, currentSquare: currentSquare, newSquare: intermediateSquare, isCapture: false), computeNextLegalMoves: false).isPlayerInCheck(player: playerToMove) {
                                moves.append(Move(withPieceCastlingLong: piece))
                            }
                        }
                    }
                }
            }
        }
        
        return moves.filter { move in
            let tmpBoard = self.getChessboardAfterMove(move: move, computeNextLegalMoves: false)
            return !tmpBoard.isPlayerInCheck(player: move.piece.color)
        }
    }
    
    func legalMovesForPieceAtSquare(square: BoardSquare) -> [Move] {
        return Array(self.legalMoves.values.filter { move in
            move.currentSquare == square
        })
    }
    
    // Interpreting UCI move sequence
    func movesFromUCIVariation(sequence: [String]) -> (Move?, String) {
        var firstMove: Move? = nil
        var line: String = ""
        
        var currentBoard: Chessboard = self
        
        for moveText in sequence {
            if moveText.count != 4 && moveText.count != 5 {
                continue
            }
            
            let startFile = BoardSquare.fileReverseMapping[String(moveText[moveText.index(moveText.startIndex, offsetBy: 0)])] ?? 0
            let startRank = Int(String(moveText[moveText.index(moveText.startIndex, offsetBy: 1)])) ?? 0
            let startSquare = BoardSquare(rank: 8 - startRank, file: startFile)
            let endFile = BoardSquare.fileReverseMapping[String(moveText[moveText.index(moveText.startIndex, offsetBy: 2)])] ?? 0
            let endRank = Int(String(moveText[moveText.index(moveText.startIndex, offsetBy: 3)])) ?? 0
            let endSquare = BoardSquare(rank: 8 - endRank, file: endFile)
            let promotion: PieceType? = moveText.count == 5 ? PieceType.fromDescription(description: String(moveText[moveText.index(moveText.startIndex, offsetBy: 4)])) : nil
            
            for (notation, move) in currentBoard.legalMoves {
                if move.currentSquare == startSquare && move.newSquare == endSquare && move.promotion == promotion {
                    
                    if move.piece.color == .white {
                        line += String(currentBoard.fullmoveNumber) + ". " + notation + " "
                    } else if firstMove == nil {
                        line += String(currentBoard.fullmoveNumber) + "... " + notation + " "
                    } else {
                        line += notation + " "
                    }
                    
                    if firstMove == nil {
                        firstMove = move
                    }
                    
                    currentBoard = currentBoard.getChessboardAfterMove(move: move)
                    break
                }
            }
        }
        
        return (firstMove, line)
    }
}
