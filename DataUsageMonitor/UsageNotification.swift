//
//  UsageNotification.swift
//  DataUsageMonitor
//
//  Created by niklas on 16.07.22.
//

import Cocoa
import UserNotifications

class Limit {
    var limit: Int
    var isActive: Bool
    var isNotified: Bool
    
    init(limit: Int, isActive: Bool = false) {
        self.limit = limit
        self.isActive = UserDefaults.standard.bool(forKey: "limit_\(limit)_isActive")
        self.isNotified = false
    }
}

class UsageNotification {
    let center = UNUserNotificationCenter.current()
    let menuItem = NSMenuItem(title: NSLocalizedString("usage_notification.menu", comment: "Notification at"), action: nil, keyEquivalent: "u")

    // 8, 50, 60, 70, 75, 80, 85, 90, 95, 100
    let limits: [Limit] = [
        Limit(limit: 100),
        Limit(limit: 95),
        Limit(limit: 90),
        Limit(limit: 85),
        Limit(limit: 80),
        Limit(limit: 60),
        Limit(limit: 75),
        Limit(limit: 70),
        Limit(limit: 50),
    ]

    func checkLimits(currentUsage: Int) {
        print("Checking limits for \(currentUsage)")
        for limit in limits {
            if limit.isActive && currentUsage >= limit.limit {
                if !limit.isNotified {
                    limit.isNotified = true
                    showNotification(limit)
                    break
                }
            }
        }
    }
    
    func requestPermission() {
        self.center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if granted {
                print("Notification permission granted")
            } else {
                print("not granted")
                //self.showPermissionDeniedAlert()
            }
        }
    }

    func getMenu() -> NSMenuItem {
        let menu = NSMenu()
        self.menuItem.submenu = menu
        
        for limit in limits {
            // mark current limit as selected
            let limitMenuItem = NSMenuItem(title: "\(limit.limit)%", action: #selector(setLimit), keyEquivalent: "")
            limitMenuItem.target = self
            limitMenuItem.tag = limit.limit

            if limit.isActive {
                requestPermission()
                limitMenuItem.state = .on
            }

            menu.addItem(limitMenuItem)
        }
        
        return menuItem
    }

    // function which is called when a limit is selected from the menu
    @objc func setLimit(_ sender: NSMenuItem) {
        for limit in limits {
            if limit.limit == sender.tag {
                limit.isActive = !limit.isActive
                sender.state = limit.isActive ? .on : .off
                UserDefaults.standard.set(limit.isActive, forKey: "limit_\(limit.limit)_isActive")
            }
        }
        UserDefaults.standard.synchronize()
    }
        
    func showNotification(_ forLimit: Limit) -> Void {
        let content = UNMutableNotificationContent()
        // show notification with current usage
        content.title = NSLocalizedString("usage_notification.title", comment: "Data usage limit reached")
        content.body = String.localizedStringWithFormat(
            NSLocalizedString("usage_notification.body", comment: "Reached a certain percentage of your data plan"),
            String(forLimit.limit))
        
        // content.body = "You've reached " + String(forLimit.limit) + "% of your data plan"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        // Create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        // Schedule the request with the system.
        self.center.add(request, withCompletionHandler: { (error) in
            if error != nil {
                // Something went wrong
            }
        })
    }
}
