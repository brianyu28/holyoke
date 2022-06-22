//
//  UTType.swift
//  Holyoke
//
//  Created by Brian Yu on 6/22/22.
//

import Foundation
import UniformTypeIdentifiers

extension UTType {
    
    /**
     Type identifier for a chess PGN file.
     */
    static var pgnType: UTType {
        UTType(filenameExtension: "pgn", conformingTo: .text)!
    }
}
