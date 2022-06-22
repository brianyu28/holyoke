//
//  ChessboardSquareStyle.swift
//  Holyoke
//
//  Created by Brian Yu on 6/22/22.
//

import SwiftUI

struct ChessboardSquareStyle {
    let darkSquareColor: Color
    let lightSquareColor: Color
    
    static var defaultStyle: ChessboardSquareStyle {
        return ChessboardSquareStyle(
            darkSquareColor: Color(red: 0.541, green: 0.451, blue: 0.298),
            lightSquareColor: Color(red: 0.839, green: 0.769, blue: 0.647)
        )
    }
}
