//
//  ChessEngine.swift
//  Holyoke
//
//  Created by Brian Yu on 6/20/22.
//

import Foundation
import SwiftUI

struct Line {
    let depth: Int
    let cp: Double
    let move: Move
    let variation: String
}

class ChessEngine: ObservableObject {
    
    static let sharedInstance = ChessEngine()
    
    var currentBoard: Chessboard?
    @Published var task: Process?
    
    // TODO: Make this not a string?
    @Published var lines: [Line?]
    
    // TODO: Allow configuration of these parameters
    static private let enginePath = "/opt/homebrew/bin/stockfish"
    static private let numVariations = 5
    
    init() {
        task = nil
        currentBoard = nil
        lines = []
    }
    
    var isRunningEngine: Bool {
        self.task != nil
    }
    
    func handlePossibleLine(line: String) {
        guard let currentBoard = currentBoard else {
            return
        }

        // Example: info depth 19 seldepth 28 multipv 1 score cp 36 nodes 1119774 nps 487281 hashfull 478 tbhits 0 time 2298 pv d2d4 d7d5 c2c4 e7e6 g1f3 d5c4 e2e4 b7b5 a2a4 c7c6 a4b5 c6b5 b2b3 g8f6 b3c4 b5c4 f1c4 f6e4 e1g1 f8e7 d4d5 e8g8 d5e6 c8e6 c4e6
        let components = line.components(separatedBy: .whitespacesAndNewlines)
        
        let infoIndices = components.allIndices(of: "info")
        
        for i in infoIndices.indices {
            let subcomponents = i < infoIndices.indices.count - 1 ? Array(components[infoIndices[i]...(infoIndices[i + 1] - 1)]) : Array(components[infoIndices[i]...])
            
            // Get which line number this is
            let multipvLabelIndex = subcomponents.firstIndex(of: "multipv")
            let lineNumberStr = multipvLabelIndex != nil ? subcomponents[optional: multipvLabelIndex! + 1] : nil
            guard let lineNumber: Int = Int(lineNumberStr ?? "") else {
                return
            }
            let lineIndex = lineNumber - 1
            while self.lines.count <= lineIndex {
                self.lines.append(nil)
            }
            
            // Get depth
            let depthIndex = subcomponents.firstIndex(of: "depth")
            let depth = depthIndex != nil ? subcomponents[optional: depthIndex! + 1] : nil
            guard let depth = Int(depth ?? "") else {
                return
            }
                        
            // Get centipawn score
            let cpLabelIndex = subcomponents.firstIndex(of: "cp")
            let cp = cpLabelIndex != nil ? subcomponents[optional: cpLabelIndex! + 1] : nil
            guard let cp = cp, let cpInt = Int(cp) else {
                return
            }
            let cpDouble = self.currentBoard?.playerToMove == .black ? (-1.0 * Double(cpInt)) / 100.0 : Double(cpInt) / 100.0
            
            // Get principal variation
            let pvLabelIndex = subcomponents.firstIndex(of: "pv")
            guard let pvLabelIndex = pvLabelIndex else {
                return
            }
            let variation = Array(subcomponents[(pvLabelIndex + 1)...])

            let (move, line): (Move?, String) = currentBoard.movesFromUCIVariation(sequence: variation)
            guard let move = move else {
                return
            }

            self.lines[lineIndex] = Line(
                depth: depth,
                cp: cpDouble,
                move: move,
                variation: line
            )
        }
    }
    
    func run(board: Chessboard) {
        
        // If there's currently a task running, stop it
        if task != nil  {
            self.stop(clearLines: true)
        }
        
        self.currentBoard = board
        
        self.task = Process()
        guard let task = self.task else {
            return
        }

        task.executableURL = URL(fileURLWithPath: Self.enginePath)
        task.arguments = []
        
        let inputPipe = Pipe()
        task.standardInput = inputPipe
        let writeHandle = inputPipe.fileHandleForWriting
        
        // https://stackoverflow.com/q/33820746
        let pipe = Pipe()
        task.standardOutput = pipe
        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()
        
        var progressObserver : NSObjectProtocol!
        progressObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSFileHandleDataAvailable,
            object: outHandle, queue: nil)
        {
            notification -> Void in
            let data = outHandle.availableData

            if data.count > 0 {
                if let str = String(data: data, encoding: String.Encoding.utf8) {
                    self.handlePossibleLine(line: str)
                }
                outHandle.waitForDataInBackgroundAndNotify()
            } else {
                // That means we've reached the end of the input.
                NotificationCenter.default.removeObserver(progressObserver!)
            }
        }

        var terminationObserver : NSObjectProtocol!
        terminationObserver = NotificationCenter.default.addObserver(
            forName: Process.didTerminateNotification,
            object: task, queue: nil)
        {
            notification -> Void in
            // Done running process
            NotificationCenter.default.removeObserver(terminationObserver!)
        }

        task.launch()
        
        do {
            try writeHandle.write(contentsOf: Data("position fen \(board.fen)\n".data(using: .utf8)!))
            try writeHandle.write(contentsOf: Data("setoption name MultiPV value \(Self.numVariations)\n".data(using: .utf8)!))
            try writeHandle.write(contentsOf: Data("go infinite\n".data(using: .utf8)!))
            // try writeHandle.close()
        } catch {
            
        }
    }
    
    func stop(clearLines: Bool) {
        if clearLines {
            self.lines = []
        }
        self.currentBoard = nil
        
        guard let task = task else {
            return
        }

        task.terminate()
        self.task = nil
    }
}
