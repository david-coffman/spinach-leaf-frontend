//
//  AudioController.swift
//  SensorSuite
//
//  Created by David Coffman on 11/17/21.
//

import Foundation
import AVKit

class AudioController<DSType: SensorDataSource> {
    var audioPlayer: AVAudioPlayer
    var dataSource: DSType
    var timer: Timer?
    
    init(dataSource: DSType) {
        let sound = Bundle.main.path(forResource: "beep", ofType: "mp3")
        self.audioPlayer = try! AVAudioPlayer.init(contentsOf: URL(fileURLWithPath: sound!))
        self.audioPlayer.enableRate = true
        self.dataSource = dataSource
    }
    
    func start(refreshRate: Double, maxAudioDistance: Double) {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0/refreshRate, repeats: true) { [self] timer in
            guard timer.isValid else { return }
            let minDistance = Sensor.allCases.map({dataSource.getDataForSensor(sensor: $0)}).reduce(Double.infinity, {min($0, $1)})
            if (minDistance > maxAudioDistance || minDistance == 0) {
                self.audioPlayer.stop()
            } else {
                self.audioPlayer.play()
                let rateFraction = 1.0 - minDistance/maxAudioDistance
                let rateRange = 10.0 - 0.5
                let rateAdjustment = rateFraction * rateRange
                let rateBase = 0.25
                self.audioPlayer.rate = Float(rateBase + rateAdjustment)
                self.audioPlayer.volume = Float(rateFraction)
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
