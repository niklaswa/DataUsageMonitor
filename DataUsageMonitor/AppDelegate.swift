//
//  AppDelegate.swift
//  DataUsageMonitor
//
//  Created by niklas on 06.07.22.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    private var window: NSWindow!
    private var statusItem: NSStatusItem!
    private var button: NSStatusBarButton!
    private var title: String = "📡"
    
    private var fetchTimer: Timer?
    
    private var provider: UsageProvider?
    
    private var extraInfoMenuItem: NSMenuItem!
    
    private var usageNotification: UsageNotification?


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.button = statusItem.button
        
        let statusBarMenu = NSMenu(title: NSLocalizedString("app.name", comment: "App name"))
        statusItem.menu = statusBarMenu
        
        self.extraInfoMenuItem = NSMenuItem(title: NSLocalizedString("app.waiting", comment: "Waiting for connection"), action: nil, keyEquivalent: "")
        self.extraInfoMenuItem.image = NSImage(systemSymbolName: "antenna.radiowaves.left.and.right", accessibilityDescription: "Extra Info")
        statusItem.menu?.addItem(self.extraInfoMenuItem)

        self.usageNotification = UsageNotification()
        self.usageNotification!.requestPermission()
        statusBarMenu.addItem(self.usageNotification!.getMenu())
        
        let quitMenuItem = NSMenuItem(title: NSLocalizedString("app.quit", comment: "Quit application"), action: #selector(quit), keyEquivalent: "q")
        quitMenuItem.image = NSImage(systemSymbolName: "power", accessibilityDescription: "Quit")
        statusBarMenu.addItem(quitMenuItem)

        
        if let button = statusItem.button {
            button.title = self.title
        }
        
        self.provider = Telekom()
        self.startFetching()
    }

    @objc func fetchInfo() {
        self.provider?.fetchData()
        
        if self.provider?.usedPercentage != nil {
            self.usageNotification?.checkLimits(currentUsage: self.provider!.usedPercentage!)

            let title = String(self.provider!.usedPercentage!) + "%"
            DispatchQueue.main.async {
                if let button = self.statusItem.button {
                    button.title = title
                    // button.image = NSImage(named: NSImage.Name("T_logo_rgb_n"))
                }
                
                self.extraInfoMenuItem.title = self.provider!.usedVolumeStr! + " / " + self.provider!.initialVolumeStr!
                self.extraInfoMenuItem.action = #selector(self.openInfoPage)
            }
        }
    }
    
    func startFetching() {
        self.fetchInfo()
        self.fetchTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(fetchInfo), userInfo: nil, repeats: true)
    }
    
    func stopFetching() {
        self.fetchTimer?.invalidate()
        self.fetchTimer = nil
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    @objc func openInfoPage() {
        if self.provider == nil {
            return
        }
        
        let url = URL(string: self.provider!.infoPageUrl)!
        NSWorkspace.shared.open(url)
    }

    
    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
}

