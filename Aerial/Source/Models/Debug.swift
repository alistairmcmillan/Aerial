//
//  Debug.swift
//  Aerial
//
//  Created by John Coates on 10/28/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

import Foundation

extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        } else {
            try write(to: fileURL, options: .atomic)
        }
    }
}

extension String {
    func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }

    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
}

// http://stackoverflow.com/a/39048651/35794
func reportMemory() {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

    let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
            task_info(mach_task_self_,
                      task_flavor_t(MACH_TASK_BASIC_INFO),
                      $0,
                      &count)
        }
    }

    if kerr == KERN_SUCCESS {
        debugLog("Memory in use (in bytes): \(info.resident_size)")
    } else {
        debugLog("Error with task_info(): " +
            (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"))
    }
}

func debugLog(_ message: String) {
        do {
            let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            let url = dir.appendingPathComponent("aerial_debug_\(Host.current().localizedName ?? "")_\(formatter.string(from: Date())).log")
            try "\(Date()) : \(message)".appendLineToURL(fileURL: url as URL)
            _ = try String(contentsOf: url as URL, encoding: String.Encoding.utf8)
        } catch {
            /* error handling here */
        }
}
