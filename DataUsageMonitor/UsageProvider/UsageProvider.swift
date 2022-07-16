//
//  UsageProvider.swift
//  DataUsageMonitor
//
//  Created by niklas on 06.07.22.
//

import Foundation

class UsageProvider {
    var infoPageUrl: String = ""
    var usedPercentage: Int?
    var usedVolumeStr: String?
    var initialVolumeStr: String?
    
    let decoder = JSONDecoder()
    
    func fetchData() {}
}
