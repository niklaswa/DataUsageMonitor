//
//  Telekom.swift
//  DataUsageMonitor
//
//  Created by niklas on 06.07.22.
//

import Foundation

class Telekom: UsageProvider {
    let statusUrl = "https://pass.telekom.de/api/service/generic/v1/status"
    // let statusUrl = "https://mocki.io/v1/8d170463-f797-4edd-a78b-b7cf99a3e9f3"
    
    struct Status: Decodable {
        var nextUpdate: Int
        var passName: String
        var usedVolumeStr: String
        var usedPercentage: Int
        var remainingTimeStr: String
        var initialVolumeStr: String
    }
    
    override init() {
        super.init()
        self.infoPageUrl = "https://pass.telekom.de"
    }
    
    override func fetchData() {
        let urlStatus = URL(string: statusUrl)!
        let taskStatus = URLSession.shared.dataTask(with: urlStatus) {(data, response, error) in
            guard let data = data else { return }
            let status: Status? = try? self.decoder.decode(Status.self, from: data)
             
            if status != nil {
                self.initialVolumeStr = status!.initialVolumeStr
                self.usedPercentage = status!.usedPercentage
                self.usedVolumeStr = status!.usedVolumeStr
            }
        }
        taskStatus.resume()
    }
}
