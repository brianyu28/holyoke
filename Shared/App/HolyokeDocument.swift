//
//  HolyokeDocument.swift
//  Shared
//
//  Created by Brian Yu on 6/8/22.
//

import SwiftUI
import UniformTypeIdentifiers

final class HolyokeDocument: ReferenceFileDocument, ObservableObject {
    
    @Published var games: [PGNGame]

    /**
     Initialize new document with blank set of games.
     */
    init() {
        self.games = PGNGameListener.parseGamesFromPGNString(pgn: "")
    }
    
    /**
     Specify that PGN documents can be read.
     */
    static var readableContentTypes: [UTType] { [.pgnType] }
    
    /**
     Initialize new document with games from file.
     */
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        self.games = PGNGameListener.parseGamesFromPGNString(pgn: string)
    }
    
    /**
     Return the games currently in the document.
     */
    func snapshot(contentType: UTType) throws -> [PGNGame] {
        return self.games
    }
    
    /**
     Write the current game data to the file.
     */
    func fileWrapper(snapshot: [PGNGame], configuration: WriteConfiguration) throws -> FileWrapper {
        var text = ""
        for game in snapshot {
            game.completeSTRMetadata()
            text += game.generatePGNText()
            text += "\n"
        }
        let data = text.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
    
    /**
     Force a manual refresh of the observed object.
     */
    func forceManualRefresh() {
        objectWillChange.send()
    }
}
