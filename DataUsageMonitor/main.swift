//
//  main.swift
//  DataUsageMonitor
//
//  Created by niklas on 06.07.22.
//

import Foundation
import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
