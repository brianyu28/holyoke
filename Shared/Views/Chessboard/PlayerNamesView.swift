//
//  PlayerNamesView.swift
//  Holyoke
//
//  Created by Brian Yu on 6/19/22.
//

import SwiftUI

struct PlayerNamesView: View {
    
    static let playerCircleSize = CGFloat(25)
    
    let whitePlayer: String
    let blackPlayer: String
    let turn: PlayerColor
    var body: some View {
        HStack {
            HStack {
                Circle()
                    .size(width: Self.playerCircleSize, height: Self.playerCircleSize)
                    .fill(.white)
                    .frame(width: Self.playerCircleSize, height: Self.playerCircleSize)
                    
                Text(whitePlayer)
                    .fontWeight(turn == .white ? .bold : .regular)
            }
            Spacer()
            HStack {
                Text(blackPlayer)
                    .fontWeight(turn == .black ? .bold : .regular)
                Circle()
                    .size(width: Self.playerCircleSize, height: Self.playerCircleSize)
                    .fill(.black)
                    .frame(width: Self.playerCircleSize, height: Self.playerCircleSize)
            }
        }
    }
}

struct PlayerNamesView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerNamesView(whitePlayer: "White", blackPlayer: "Black", turn: .white)
    }
}
