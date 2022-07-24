//
//  UtilityLogging.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import Foundation
import SwiftyBeaver

let logger: AppLogger.Type = AppLoggerSwiftyBeaver.self

open class AppLoggerSwiftyBeaver {

    public class func addDestination(_ destination: BaseDestination) {
        SwiftyBeaver.addDestination(destination)
    }

    public class func setupConsoleLogger(minLevel: SwiftyBeaver.Level = .debug, useNSLog: Bool = false) -> ConsoleDestination {
        let console = ConsoleDestination()
        console.levelColor.verbose = "📓"
        console.levelColor.debug = "📗"
        console.levelColor.info = "📘"
        console.levelColor.warning = "📙"
        console.levelColor.error = "📕"
        console.format = "$DHH:mm:ss.SSS$d $C $L $c$C$c $N.$F:$l - $M $X"
        console.minLevel = minLevel
        console.asynchronously = false
        console.useNSLog = useNSLog
        return console
    }

    public class func setupFileLogger(minLevel: SwiftyBeaver.Level = .debug) -> FileDestination {
        let file = FileDestination()
        file.minLevel = minLevel
        file.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d *$L* $N.$F:$l - $M"
        return file
    }
}

extension AppLoggerSwiftyBeaver: AppLogger {

    open class func verbose(_ message: @autoclosure () -> Any,
                            _ context: Any? = nil,
                            file: String = #file,
                            function: String = #function,
                            line: Int = #line) {
        SwiftyBeaver.verbose(message(), file, function, line: line, context: context)
    }

    open class func debug(_ message: @autoclosure () -> Any,
                          _ context: Any? = nil,
                          file: String = #file,
                          function: String = #function,
                          line: Int = #line) {
        SwiftyBeaver.debug(message(), file, function, line: line, context: context)
    }

    open class func info(_ message: @autoclosure () -> Any,
                            _ context: Any? = nil,
                            file: String = #file,
                            function: String = #function,
                            line: Int = #line) {
        SwiftyBeaver.info(message(), file, function, line: line, context: context)
    }

    open class func warning(_ message: @autoclosure () -> Any,
                            _ context: Any? = nil,
                            file: String = #file,
                            function: String = #function,
                            line: Int = #line) {
        SwiftyBeaver.warning(message(), file, function, line: line, context: context)
    }

    open class func error(_ message: @autoclosure () -> Any,
                          _ context: Any? = nil,
                          file: String = #file,
                          function: String = #function,
                          line: Int = #line) {
        SwiftyBeaver.error(message(), file, function, line: line, context: context)
    }
}
