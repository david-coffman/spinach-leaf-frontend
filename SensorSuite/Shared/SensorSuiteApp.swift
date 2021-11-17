//
//  SensorSuiteApp.swift
//  Shared
//
//  Created by David Coffman on 11/8/21.
//

import SwiftUI

@main
struct SensorSuiteApp: App {
    static let APP_REFRESH_RATE = 10.0 // hertz
    static let APP_MAX_DISTANCE = 50.0 // centimeters
    
    var suite: SensorSuite
    var audioController: AudioController<SensorSuite>
    
    init() {
        self.suite = SensorSuite()
        self.audioController = AudioController(dataSource: suite)
        self.audioController.start(refreshRate: SensorSuiteApp.APP_REFRESH_RATE, maxAudioDistance: SensorSuiteApp.APP_MAX_DISTANCE)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(sensorController: suite, sensorDataSource: suite)
            #if os(macOS)
                .frame(width: 600, height: 800, alignment: .center)
            #endif
                
        }
    }
}
