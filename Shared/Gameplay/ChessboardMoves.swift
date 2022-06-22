//
//  ChessboardMoves.swift
//  Holyoke
//
//  Created by Brian Yu on 6/22/22.
//

import Foundation

/**
 Logic for movement of pieces on a `Chessboard`.
 */
extension Chessboard {
    /**
     Check if a square is valid for a player to move a piece to.
     
     - Parameters:
        - square: The square to verify.
        - player: The color of the player making the move.
     
     - Returns: A tuple `(isValid: Bool, isCapture: Bool)`.
     `isValid` represents whether the square is valid; that is, an empty square or a capturing square.
     `isCapture` represents whether the move would be a capture if the piece were to move to the square.
     */
    func isValidMovementSquare(square: BoardSquare, player: PlayerColor) -> (isValid: Bool, isCapture: Bool) {
        if !square.isValidSquare {
            return (isValid: false, isCapture: false)
        }
        let piece = self.pieceAt(rank: square.rank, file: square.file)
        if piece == nil {
            return (isValid: true, isCapture: false)
        } else if piece!.color == player.nextColor {
            if piece!.type == .king {
                return (isValid: false, isCapture: false)
            } else {
                return (isValid: true, isCapture: true)
            }
        } else {
            return (isValid: false, isCapture: false)
        }
    }
    
    /**
     Computes the legal moves in the current position.
     
     - Returns: A list of legal moves.
     */
    func legalMovesInCurrentPosition() -> [Move] {
        var moves: [Move] = []
        
        // Check for all possible moves
        for (piece, currentSquare) in self.piecesForPlayer(player: playerToMove) {
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
                            moves.append(Move(withPawnPromoting: piece, toPiece: pieceType, startSquare: currentSquare, endSquare: nextSquare, isCapture: false))
                        }
                    } else {
                        // Non-promotion
                        moves.append(Move(piece: piece, startSquare: currentSquare, endSquare: nextSquare, isCapture: false))
                        
                        // Allow pawns to move two squares forward on the first move
                        if currentSquare.rank == (playerToMove == .white ? 6 : 1) {
                            let twoSquaresAhead = BoardSquare(rank: playerToMove == .white ? currentSquare.rank - 2 : currentSquare.rank + 2, file: currentSquare.file)
                            let twoSquareInfo = self.isValidMovementSquare(square: twoSquaresAhead, player: playerToMove)
                            if twoSquareInfo.isValid && !twoSquareInfo.isCapture {
                                moves.append(Move(piece: piece, startSquare: currentSquare, endSquare: twoSquaresAhead, isCapture: false))
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
                                moves.append(Move(withPawnPromoting: piece, toPiece: pieceType, startSquare: currentSquare, endSquare: capturingSquare, isCapture: true))
                            }
                        } else {
                            // Non-Promotion
                            moves.append(Move(piece: piece, startSquare: currentSquare, endSquare: capturingSquare, isCapture: true))
                        }
                    }
                }
                
                // Check if En Passant is allowed
                if let enPassantTarget = enPassantTarget {
                    if currentSquare.rank == (playerToMove == .white ? 3 : 4) && enPassantTarget.rank == (playerToMove == .white ? 2 : 5) && abs(enPassantTarget.file - currentSquare.file) == 1 {
                        moves.append(Move(withEnPassantByPawn: piece, startSquare: currentSquare, endSquare: BoardSquare(rank: playerToMove == .white ? 2 : 5, file: enPassantTarget.file)))
                    }
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
                            moves.append(Move(piece: piece, startSquare: currentSquare, endSquare: possibleSquare, isCapture: squareInfo.isCapture))
                        }
                    }
                }

            case .bishop:
                
                for (rankDirection, fileDirection) in Self.diagionalDirections {
                    var candidateSquare = BoardSquare(rank: currentSquare.rank + rankDirection, file: currentSquare.file + fileDirection)
                    while (true) {
                        let squareInfo = self.isValidMovementSquare(square: candidateSquare, player: playerToMove)
                        if squareInfo.isValid {
                            moves.append(Move(piece: piece, startSquare: currentSquare, endSquare: candidateSquare, isCapture: squareInfo.isCapture))
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
                            moves.append(Move(piece: piece, startSquare: currentSquare, endSquare: candidateSquare, isCapture: squareInfo.isCapture))
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
                            moves.append(Move(piece: piece, startSquare: currentSquare, endSquare: candidateSquare, isCapture: squareInfo.isCapture))
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
                        moves.append(Move(piece: piece, startSquare: currentSquare, endSquare: candidateSquare, isCapture: squareInfo.isCapture))
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
                            if !self.getChessboardAfterMove(move: Move(piece: piece, startSquare: currentSquare, endSquare: intermediateSquare, isCapture: false), computeNextLegalMoves: false).isPlayerInCheck(player: playerToMove) {
                                moves.append(Move(withPieceCastlingShort: piece))
                            }
                        }
                    }
                    if playerToMove == .white && self.whiteRightToCastleQueenside {
                        let betweenSquares = [BoardSquare(rank: 7, file: 1), BoardSquare(rank: 7, file: 2), BoardSquare(rank: 7, file: 3)]
                        let intermediateSquare = BoardSquare(rank: 7, file: 3)
                        if betweenSquares.allSatisfy( { square in self.pieceAt(rank: square.rank, file: square.file) == nil } ) {
                            if !self.getChessboardAfterMove(move: Move(piece: piece, startSquare: currentSquare, endSquare: intermediateSquare, isCapture: false), computeNextLegalMoves: false).isPlayerInCheck(player: playerToMove) {
                                moves.append(Move(withPieceCastlingLong: piece))
                            }
                        }
                    }
                    if playerToMove == .black && self.blackRightToCastleKingside {
                        let betweenSquares = [BoardSquare(rank: 0, file: 5), BoardSquare(rank: 0, file: 6)]
                        let intermediateSquare = BoardSquare(rank: 0, file: 5)
                        if betweenSquares.allSatisfy( { square in self.pieceAt(rank: square.rank, file: square.file) == nil } ) {
                            if !self.getChessboardAfterMove(move: Move(piece: piece, startSquare: currentSquare, endSquare: intermediateSquare, isCapture: false), computeNextLegalMoves: false).isPlayerInCheck(player: playerToMove) {
                                moves.append(Move(withPieceCastlingShort: piece))
                            }
                        }
                    }
                    if playerToMove == .black && self.blackRightToCastleQueenside {
                        let betweenSquares = [BoardSquare(rank: 0, file: 1), BoardSquare(rank: 0, file: 2), BoardSquare(rank: 0, file: 3)]
                        let intermediateSquare = BoardSquare(rank: 0, file: 3)
                        if betweenSquares.allSatisfy( { square in self.pieceAt(rank: square.rank, file: square.file) == nil } ) {
                            if !self.getChessboardAfterMove(move: Move(piece: piece, startSquare: currentSquare, endSquare: intermediateSquare, isCapture: false), computeNextLegalMoves: false).isPlayerInCheck(player: playerToMove) {
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
    
    /**
    Compute legal moves in the current position, saves them in the `legalMoves` property.
     */
    func computeAndSaveLegalMoves() {
        // If we've already computed legal moves, no additional action needed
        if self.legalMoves.count > 0 {
            return
        }
        
        let moveList = self.legalMovesInCurrentPosition()
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
                    moveName += "\(move.startSquare.fileNotation)x"
                }
                moveName += move.endSquare.notation
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
                    move.endSquare.rank == otherMove.endSquare.rank &&
                    move.endSquare.file == otherMove.endSquare.file
                }
                
                var moveName = ""
                if ambiguousMoves.count == 1 {
                    moveName += move.piece.type.description
                } else if (ambiguousMoves.filter { otherMove in move.startSquare.file == otherMove.startSquare.file }).count == 1 {
                    moveName += move.piece.type.description + move.startSquare.fileNotation
                } else if (ambiguousMoves.filter { otherMove in move.startSquare.rank == otherMove.startSquare.rank }).count == 1 {
                    moveName += move.piece.type.description + move.startSquare.rankNotation
                } else {
                    moveName += move.piece.type.description + move.startSquare.notation
                }
                if move.isCapture {
                    moveName += "x"
                }
                moveName += move.endSquare.notation
                self.legalMoves[moveName + suffix] = move
            }
        }
    }
    
    /**
     Returns the `Chessboard` that results from making a move in the current position.
     
     - Parameters:
        - move: The move to make.
        - computeNextLegalMove: Whether to compute legal moves in the new position.
        
     - Returns: A new `Chessboard` with the move made.
     */
    func getChessboardAfterMove(move: Move, computeNextLegalMoves: Bool = true) -> Chessboard {
        
        // Ensure there is a piece at the start square
        guard let piece = self.pieceAt(rank: move.startSquare.rank, file: move.startSquare.file) else {
            return self
        }
        
        // Create a new position based on the current position
        var newPosition = Self.emptyPosition()
        for rank in 0...7 {
            for file in 0...7 {
                newPosition[rank][file] = self.position[rank][file]
            }
        }
        
        // Make move
        newPosition[move.startSquare.rank][move.startSquare.file] = nil
        newPosition[move.endSquare.rank][move.endSquare.file] = piece
        
        // Check for en passant
        if move.isEnPassant {
            newPosition[piece.color == .white ? move.endSquare.rank + 1 : move.endSquare.rank - 1][move.endSquare.file] = nil
        }
        
        if let promotionPieceType = move.promotion {
            newPosition[move.endSquare.rank][move.endSquare.file] = Piece(color: piece.color, type: promotionPieceType)
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
        
        let enPassantTarget: BoardSquare? = {
            if move.piece.type == .pawn && move.piece.color == .white && move.startSquare.rank == 6 && move.endSquare.rank == 4 {
                return BoardSquare(rank: 5, file: move.startSquare.file)
            } else if move.piece.type == .pawn && move.piece.color == .black && move.startSquare.rank == 1 && move.endSquare.rank == 3 {
                return BoardSquare(rank: 2, file: move.startSquare.file)
            } else {
                return nil
            }
        }()
        
        let whiteRightToCastleKingside = self.whiteRightToCastleKingside &&
            !(move.piece.color == .white && move.piece.type == .king) &&
            !(move.piece.color == .white && move.piece.type == .rook && move.startSquare.rank == 7 && move.startSquare.file == 7)
        
        let whiteRightToCastleQueenside = self.whiteRightToCastleQueenside &&
            !(move.piece.color == .white && move.piece.type == .king) &&
            !(move.piece.color == .white && move.piece.type == .rook && move.startSquare.rank == 7 && move.startSquare.file == 0)
        
        let blackRightToCastleKingside = self.blackRightToCastleKingside &&
            !(move.piece.color == .black && move.piece.type == .king) &&
            !(move.piece.color == .black && move.piece.type == .rook && move.startSquare.rank == 0 && move.startSquare.file == 7)
        
        let blackRightToCastleQueenside = self.blackRightToCastleQueenside &&
            !(move.piece.color == .black && move.piece.type == .king) &&
            !(move.piece.color == .black && move.piece.type == .rook && move.startSquare.rank == 0 && move.startSquare.file == 0)
        
        let board = Chessboard(
            position: newPosition,
            playerToMove: self.playerToMove.nextColor,
            enPassantTarget: enPassantTarget,
            fullmoveNumber: piece.color == .white ? self.fullmoveNumber : self.fullmoveNumber + 1,
            halfmoveClock: piece.type != .pawn && !move.isCapture ? self.halfmoveClock + 1 : 0,
            whiteRightToCastleKingside: whiteRightToCastleKingside,
            whiteRightToCastleQueenside: whiteRightToCastleQueenside,
            blackRightToCastleKingside: blackRightToCastleKingside,
            blackRightToCastleQueenside: blackRightToCastleQueenside
        )
        
        if computeNextLegalMoves {
            board.computeAndSaveLegalMoves()
        }
        
        return board
    }
    
    /**
    Returns the legal moves for the piece currently at a particular square.
     
     - Parameters:
        - square: The current square for the piece.
     
     - Returns: The list of valid moves for the piece.
     */
    func legalMovesForPieceAtSquare(square: BoardSquare) -> [Move] {
        return Array(self.legalMoves.values.filter { move in
            move.startSquare == square
        })
    }
}
