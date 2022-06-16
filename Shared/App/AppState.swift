//
//  AppState.swift
//  Holyoke
//
//  Created by Brian Yu on 6/15/22.
//

import Foundation

class AppState: ObservableObject {
    @Published var chessboard: Chessboard
    
    init(chessboard: Chessboard) {
        self.chessboard = chessboard
    }
}
