//
//  HolyokeApp.swift
//  Shared
//
//  Created by Brian Yu on 6/8/22.
//

import SwiftUI

@main
struct HolyokeApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: HolyokeDocument.init) { file in
            ContentView(state: DocumentState(document: file.document))
        }
    }
}
