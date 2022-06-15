//
//  PGN.swift
//  Holyoke
//
//  Created by Brian Yu on 6/15/22.
//

import Foundation

struct PGNGame {
    /**
     Game metadata. Standard game metadata includes "Event", "Site", "Date", "Round", "White", "Black", "Result"
     */
    let metadata : [(field: String, value: String)]
    
    /**
     Tree of moves.
     */
    let tree : PGNGameTree
}

/**
 Represents a node in a tree of moves.
 */
struct PGNGameTree {
    let moveNumber : Int
    let playerColor : PlayerColor
    let moveText : String
    let commentary : String
    let annotations : String
    let lines : [PGNGameTree]
}


class PGNGameListener : PGNBaseListener {
    
    override init() {
        
    }
    
    override func enterElement(_ ctx: PGNParser.ElementContext) {
        print(ctx.san_move()?.SYMBOL())
    }
}
