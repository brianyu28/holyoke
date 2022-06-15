//
//  Game.swift
//  Holyoke (iOS)
//
// Defines game data.
//
//  Created by Brian Yu on 6/8/22.
//

import Foundation

/**
 Structure representing a chess game.
 */
struct Game {
    /**
     Game metadata. Standard game metadata includes "Event", "Site", "Date", "Round", "White", "Black", "Result"
     */
    let metadata : [(field: String, value: String)]
    
    /**
     Tree of moves.
     */
    let tree : GameTree
}

/**
 Represents a node in a tree of moves.
 */
struct GameTree {
    // Move
    let move : Move
    
    // Which player's turn
    let player : PlayerColor
    
    // Comments on the move
    let commentary : String
    
    // Annotations on the move itself, e.g. !, ?, !!, ?!
    let annotations : String
    let lines : [GameTree]
}
