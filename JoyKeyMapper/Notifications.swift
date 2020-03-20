//
//  Notifications.swift
//  JoyConMapper
//
//  Created by magicien on 2019/07/15.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import Foundation

public extension Notification.Name {
    static let controllerAdded = Notification.Name("ControllerAdded")
    static let controllerConnected = Notification.Name("ControllerConnected")
    static let controllerDisconnected = Notification.Name("ControllerDisconnected")
    static let controllerRemoved = Notification.Name("ControllerRemoved")
    static let controllerIconChanged = Notification.Name("ControllerIconChanged")
}
