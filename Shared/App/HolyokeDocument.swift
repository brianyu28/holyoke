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

struct HolyokeDocument: FileDocument {
    var games: [PGNGame]

    init(pgnText: String) {
        self.games = PGNGameListener.parseGamesFromPGNString(pgn: pgnText)
    }

    static var readableContentTypes: [UTType] { [.exampleText] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.games = PGNGameListener.parseGamesFromPGNString(pgn: string)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let text = "Example file contents: \(games.count)" // TODO: replace with actual PGN content
        let data = text.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
}
