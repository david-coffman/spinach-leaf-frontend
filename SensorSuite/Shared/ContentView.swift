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
            Spacer()
            
            Text("Sensor Controls")
                .font(.title)
                .padding()
            
            HStack {
                Button(
                    action: {
                        sensorController.powerSensorsOn()
                    }, label: {
                        Text("Power On")
                            .foregroundColor(.white)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20))
                    })
                    .padding(.horizontal)
                Button(
                    action: {
                        sensorController.powerSensorsOff()
                    }, label: {
                        Text("Power Off")
                            .foregroundColor(.white)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20))
                    })
                    .padding(.horizontal)
            }
            .padding()
            
            Spacer()
            
            Text("Sensor Measurements")
                .font(.title)
                .padding()
            
            VStack {
                Text("Left LIDAR: \(dataSource.getDataForSensor(sensor: .LEFT_LIDAR))")
                Text("Center LIDAR: \(dataSource.getDataForSensor(sensor: .CENTER_LIDAR))")
                Text("Right LIDAR: \(dataSource.getDataForSensor(sensor: .RIGHT_LIDAR))")
            }
            .padding()
                
            HStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(sensorColor(sensor: .LEFT_LIDAR))
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(sensorColor(sensor: .CENTER_LIDAR))
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(sensorColor(sensor: .RIGHT_LIDAR))
            }
            .padding()
            .frame(height: 100)
            
            Spacer()
        }
    }
    
    func sensorColor(sensor: Sensor) -> Color {
        let distance = dataSource.getDataForSensor(sensor: sensor)
        let adjustedDistance = distance - 10.0
        if (distance <= 0) {
            return .gray
        }
        let maxDistance = 50.0
        let maxHue = 0.3
        let hue = min(maxHue * adjustedDistance / maxDistance, maxHue)
        return Color(hue: hue, saturation: 1, brightness: 0.9)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let suite = SensorSuite()
        return ContentView(sensorController: suite, sensorDataSource: suite)
    }
}
