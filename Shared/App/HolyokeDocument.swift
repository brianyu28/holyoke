//
//  HolyokeDocument.swift
//  Shared
//
//  Created by Brian Yu on 6/8/22.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var exampleText: UTType {
        UTType(importedAs: "com.example.plain-text")
    }
}

final class HolyokeDocument: ReferenceFileDocument, ObservableObject {
    
    @Published var games: [PGNGame]
    @Published var chessboard: Chessboard

    init() {
        self.games = PGNGameListener.parseGamesFromPGNString(pgn: "")
        self.chessboard = Chessboard.initInStartingPosition()
    }

    static var readableContentTypes: [UTType] { [.exampleText] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.games = PGNGameListener.parseGamesFromPGNString(pgn: string)
        self.chessboard = Chessboard.initInStartingPosition()
    }
    
    func snapshot(contentType: UTType) throws -> [PGNGame] {
        return self.games
    }
    
    func fileWrapper(snapshot: [PGNGame], configuration: WriteConfiguration) throws -> FileWrapper {
        let text = "Example file contents: \(snapshot.count)" // TODO: replace with actual PGN content
        let data = text.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
    
    // Gameplay
    
    func makeMoveOnBoard(move: Move) {
        chessboard = chessboard.getChessboardAfterMove(move: move)
    }
}
