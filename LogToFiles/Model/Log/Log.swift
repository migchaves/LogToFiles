//
//  Log.swift
//  LogToFiles
//
//  Created by Miguel on 09/01/2022.
//

import UIKit

final class Log: TextOutputStream {
    
    static var log = Log()
    
    // Define the name for the file. Using current date to
    private lazy var currentFile: String = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd-HHmmss"
        return "log_\(dateFormatter.string(from: Date())).txt"
    }()
    
    // MARK: - Init
    
    private init() { }
    
    // MARK: - Write the log message
    
    /// Write the message to the log file
    /// - Parameter string: the log message
    func write(_ string: String) {
        
        let file = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask)[0].appendingPathComponent(self.currentFile)
        
        do {
            let handle = try FileHandle(forWritingTo: file)
            handle.seekToEndOfFile()
            handle.write(string.data(using: .utf8)!)
            handle.closeFile()
        } catch {
            self.writeString(string, file)
        }
    }
    
    /// Fallback if the 'write' method fails
    /// - Parameters:
    ///   - string: the string to write
    ///   - file: the file
    private func writeString(_ string: String, _ file: URL) {
        
        guard let data = string.data(using: .utf8) else {
            return
        }
        
        do {
            try data.write(to: file)
        } catch {
            print("Error writing to log file.")
        }
    }
}
