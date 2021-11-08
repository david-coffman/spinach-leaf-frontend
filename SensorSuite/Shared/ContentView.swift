//
//  ContentView.swift
//  Shared
//
//  Created by David Coffman on 11/8/21.
//

import SwiftUI

struct ContentView<DSType>: View where DSType: SensorDataSource {
    var sensorController: SensorController
    @ObservedObject var dataSource: DSType
    
    init(sensorController: SensorController, sensorDataSource: DSType) {
        self.sensorController = sensorController
        self.dataSource = sensorDataSource
    }
    
    var body: some View {
        VStack {
            Text("Sensor Controls")
                .padding()
            Button(
                action: {
                    sensorController.powerSensorsOn()
                }, label: {
                    Text("Power On")
                })
                .padding()
            Button(
                action: {
                    sensorController.powerSensorsOff()
                }, label: {
                    Text("Power Off")
                })
                .padding()
            Text("Left LIDAR: \(dataSource.getDataForSensor(sensor: .LEFT_LIDAR))")
            Text("Center LIDAR: \(dataSource.getDataForSensor(sensor: .CENTER_LIDAR))")
            Text("Left LIDAR: \(dataSource.getDataForSensor(sensor: .RIGHT_LIDAR))")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let suite = SensorSuite()
        return ContentView(sensorController: suite, sensorDataSource: suite)
    }
}
