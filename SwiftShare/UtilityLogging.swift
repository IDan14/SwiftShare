//
//  UtilityLogging.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import Foundation
import SwiftyBeaver

public class UtilityLogging {

    public class func setupConsoleLogger(minLevel: SwiftyBeaver.Level = .debug, useNSLog: Bool = false) -> ConsoleDestination {
        let console = ConsoleDestination()
        console.levelColor.verbose = "📓"
        console.levelColor.debug = "📗"
        console.levelColor.info = "📘"
        console.levelColor.warning = "📙"
        console.levelColor.error = "📕"
        console.format = "$DHH:mm:ss.SSS$d $C $L $c$C$c $N.$F:$l - $M"
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
