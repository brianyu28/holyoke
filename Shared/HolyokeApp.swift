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
        DocumentGroup(newDocument: HolyokeDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
