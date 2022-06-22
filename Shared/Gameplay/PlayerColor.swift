//
//  PlayerColor.swift
//  Holyoke
//
//  Created by Brian Yu on 6/22/22.
//

import Foundation

/**
 Represents the color of a player or piece.
 */
enum PlayerColor {
    case white
    case black
    
    /**
     The opposite color of the current color.
     */
    var nextColor: PlayerColor {
        switch self {
        case .white:
            return .black
        case .black:
            return .white
        }
    }
}
