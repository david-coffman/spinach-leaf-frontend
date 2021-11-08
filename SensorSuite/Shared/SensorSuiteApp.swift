//
//  SensorSuiteApp.swift
//  Shared
//
//  Created by David Coffman on 11/8/21.
//

import SwiftUI

@main
struct SensorSuiteApp: App {
    var suite = SensorSuite()
    
    var body: some Scene {
        WindowGroup {
            ContentView(sensorController: suite, sensorDataSource: suite)
        }
    }
}
