//
//  AppLogger.swift
//  SwiftShare
//
//  Created by Dan ILCA on 24.07.2022.
//

import Foundation

open class AppLogger {
    open class func verbose(_ message: @autoclosure () -> Any,
                            _ context: Any? = nil,
                            file: String = #file,
                            function: String = #function,
                            line: Int = #line) {
        fatalError("Method must be overriden")
    }

    open class func debug(_ message: @autoclosure () -> Any,
                          _ context: Any? = nil,
                          file: String = #file,
                          function: String = #function,
                          line: Int = #line) {
        fatalError("Method must be overriden")
    }

    open class func info(_ message: @autoclosure () -> Any,
                         _ context: Any? = nil,
                         file: String = #file,
                         function: String = #function,
                         line: Int = #line) {
        fatalError("Method must be overriden")
    }

    open class func warning(_ message: @autoclosure () -> Any,
                            _ context: Any? = nil,
                            file: String = #file,
                            function: String = #function,
                            line: Int = #line) {
        fatalError("Method must be overriden")
    }

    open class func error(_ message: @autoclosure () -> Any,
                          _ context: Any? = nil,
                          file: String = #file,
                          function: String = #function,
                          line: Int = #line) {
        fatalError("Method must be overriden")
    }
}
