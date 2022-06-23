//
//  PGNGameNodeChessboard.swift
//  Holyoke
//
//  Created by Brian Yu on 6/22/22.
//

import Foundation

/**
 Logic to handle updating chessboards for game nodes.
 */
extension PGNGameNode {
    /**
     Computes and saves the chessboard for the current node, if not already computed.
     */
    func computeChessboardForNode() {
        // If chessboard is already saved, no need to compute
        if chessboard != nil {
            return
        }
        
        // Otherwise, we need to compute the position
        var nodes: [PGNGameNode] = []
        
        // We do so by backtracking through all nodes until we get to a node with a position
        var cursor: PGNGameNode? = self
        while (cursor != nil && cursor!.chessboard == nil) {
            nodes.append(cursor!)
            cursor = cursor!.parent
        }
        
        // If we got to the start of game and never found a chessboard, then we can't compute the position
        guard let cursor = cursor else {
            return
        }
        
        var board = cursor.chessboard!
        for node in nodes.reversed() {
            guard let moveText = node.move else {
                break
            }
            guard let move = board.legalMoves[moveText] else {
                break
            }
            board = board.getChessboardAfterMove(move: move)
        }
        
        self.chessboard = board
    }
    
    /**
     Sets the chess board position for the node.
     Propagates player to move and move number changes through child nodes.
     Useful for the initial node, which may be an arbitrary starting position.
     
     - Parameters:
        - board: The board to set for the chessboard.
     */
    func setChessboardForNode(board: Chessboard) {
        self.chessboard = board
        self.setPlayerToMove(playerToMove: board.playerToMove)
        self.setMoveNumber(moveNumber: board.playerToMove == .white ? board.fullmoveNumber - 1 : board.fullmoveNumber)
    }
    
    /**
     Set which player is to move in the current position.
     This value is propagated to all descendant nodes.
     
     - Parameters:
        - playerToMove: The player to move in the current position.
     */
    func setPlayerToMove(playerToMove: PlayerColor) {
        let currentPlayerColor = self.playerColor
        
        // playerColor should be the opposite of playerToMove,
        // since playerColor is who just moved in this node, and playerToMove is whose turn it is next
        // If they're the same, then we need to flip them
        if currentPlayerColor == playerToMove {
            self.playerColor = playerToMove.nextColor
            for variation in self.variations {
                variation.setPlayerToMove(playerToMove: playerToMove.nextColor)
            }
            
        }
    }
    
    /**
     Sets the move number for the current position.
     This also propagates the move number for all descendant nodes.
     */
    func setMoveNumber(moveNumber: Int) {
        // If the move number is already accurate, then we don't need additional action
        if self.moveNumber == moveNumber {
            return
        }
        self.moveNumber = moveNumber
        let nextMoveNumber = playerColor == .white ? moveNumber : moveNumber + 1
        for variation in self.variations {
            variation.setMoveNumber(moveNumber: nextMoveNumber)
        }
    }
}
