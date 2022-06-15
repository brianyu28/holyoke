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

