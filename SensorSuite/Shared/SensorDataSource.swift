//
//  SensorDataSource.swift
//  SensorSuite
//
//  Created by David Coffman on 11/8/21.
//

import Foundation

enum Sensor: CaseIterable {
    case LEFT_LIDAR
    case CENTER_LIDAR
    case RIGHT_LIDAR
}

protocol SensorDataSource: ObservableObject {
    func getDataForSensor(sensor: Sensor) -> Double
}
