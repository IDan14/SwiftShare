//
//  AppLogger.swift
//  SwiftShare
//
//  Created by Dan ILCA on 24.07.2022.
//

import Foundation

public protocol AppLogger {
    static func verbose(_ message: @autoclosure () -> Any, _ context: Any?, file: String, function: String, line: Int)
    static func debug(_ message: @autoclosure () -> Any, _ context: Any?, file: String, function: String, line: Int)
    static func info(_ message: @autoclosure () -> Any, _ context: Any?, file: String, function: String, line: Int)
    static func warning(_ message: @autoclosure () -> Any, _ context: Any?, file: String, function: String, line: Int)
    static func error(_ message: @autoclosure () -> Any, _ context: Any?, file: String, function: String, line: Int)
}

public extension AppLogger {
    static func verbose(_ message: @autoclosure () -> Any,
                        _ context: Any? = nil,
                        file: String = #file,
                        function: String = #function,
                        line: Int = #line) {
        verbose(message(), context, file: file, function: function, line: line)
    }

    static func debug(_ message: @autoclosure () -> Any,
                      _ context: Any? = nil,
                      file: String = #file,
                      function: String = #function,
                      line: Int = #line) {
        debug(message(), context, file: file, function: function, line: line)
    }

    static func info(_ message: @autoclosure () -> Any,
                     _ context: Any? = nil,
                     file: String = #file,
                     function: String = #function,
                     line: Int = #line) {
        info(message(), context, file: file, function: function, line: line)
    }

    static func warning(_ message: @autoclosure () -> Any,
                        _ context: Any? = nil,
                        file: String = #file,
                        function: String = #function,
                        line: Int = #line) {
        warning(message(), context, file: file, function: function, line: line)
    }

    static func error(_ message: @autoclosure () -> Any,
                      _ context: Any? = nil,
                      file: String = #file,
                      function: String = #function,
                      line: Int = #line) {
        error(message(), context, file: file, function: function, line: line)
    }
}
