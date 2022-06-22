//
//  BoardFile.swift
//  Holyoke
//
//  Created by Brian Yu on 6/22/22.
//

import Foundation

/**
 Represents the file of a square of a chessboard as a value in `[0, 7]`.
 0 represents the a file, 7 represents the h file.
 */
typealias BoardFile = Int

extension Chessboard {
    // Constants representing files by letter
    static let aFile: BoardFile = 0
    static let bFile: BoardFile = 1
    static let cFile: BoardFile = 2
    static let dFile: BoardFile = 3
    static let eFile: BoardFile = 4
    static let fFile: BoardFile = 5
    static let gFile: BoardFile = 6
    static let hFile: BoardFile = 7
    
    // Constants representing files with special meanings
    static let kingStartFile: BoardFile = Chessboard.eFile
    static let kingShortCastleEndFile: BoardFile = Chessboard.gFile
    static let kingLongCastleEndFile: BoardFile = Chessboard.cFile
    
    /**
     Range of all possible files.
     */
    static let files: ClosedRange<Int> = 0...7

    /**
     Computes whether the file is a valid file on the chessboard.
     
     - Parameters:
        - file: A file on the board.
     
     - Returns: `true` if the file is a valid file on the board, `false` otherwise.
     */
    static func isValidFile(file: BoardFile) -> Bool { Self.files.contains(file) }
    
    /**
     Returns a board file based on the SAN algebraic notation representation of the file.
     
     - Parameters:
        - string: Single-character string representing the board's file in SAN.
     
     - Returns: The board file described by the string, or `nil` if the string is invalid.
     */
    static func fileFromSan(string: String) -> BoardFile? {
        switch string {
        case "a": return Chessboard.aFile
        case "b": return Chessboard.bFile
        case "c": return Chessboard.cFile
        case "d": return Chessboard.dFile
        case "e": return Chessboard.eFile
        case "f": return Chessboard.fFile
        case "g": return Chessboard.gFile
        case "h": return Chessboard.hFile
        default: return nil
        }
    }
    
    /**
     Given a file, returns its SAN representation as a string.
     For example, for a file of `0`, this function would return `a`.
     
     - Parameters:
        - file: A file on the board.
     
     - Returns: The string ("a" through "h") representing the file, or `nil` if the file is invalid.
     */
    static func sanFromFile(file: BoardFile) -> String? {
        switch file {
        case Chessboard.aFile: return "a"
        case Chessboard.bFile: return "b"
        case Chessboard.cFile: return "c"
        case Chessboard.dFile: return "d"
        case Chessboard.eFile: return "e"
        case Chessboard.fFile: return "f"
        case Chessboard.gFile: return "g"
        case Chessboard.hFile: return "h"
        default: return nil
        }
    }
    
}
