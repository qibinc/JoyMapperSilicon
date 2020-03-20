//
//  DataManager.swift
//  JoyConMapper
//
//  Created by magicien on 2019/07/14.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import CoreData
import JoyConSwift

enum StickType: String {
    case Mouse = "Mouse"
    case MouseWheel = "Mouse Wheel"
    case Key = "Key"
    case None = "None"
}

enum StickDirection: String {
    case Left = "Left"
    case Right = "Right"
    case Up = "Up"
    case Down = "Down"
}

class DataManager: NSObject {
    let container: NSPersistentContainer

    var undoManager: UndoManager? {
        return self.container.viewContext.undoManager
    }
    
    var controllers: [ControllerData] {
        let context = self.container.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ControllerData")
        
        do {
            let result = try context.fetch(request) as! [ControllerData]
            return result
        } catch {
            fatalError("Failed to fetch ControllerData: \(error)")
        }
    }
    
    init(completion: @escaping (DataManager?) -> Void) {
        self.container = NSPersistentContainer(name: "JoyConMapper")
        super.init()
        
        self.container.loadPersistentStores { [weak self] (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
            self?.container.viewContext.automaticallyMergesChangesFromParent = true
            self?.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            
            completion(self)
        }
    }
    
    func save() -> Bool {
        let context = self.container.viewContext
         
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
            return false
        }
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)

                return false
            }
        }
        
        return true
    }
    
    func saveDataFile(to url: URL) -> Bool {
        var result: Bool = false
        do {
            let store = try self.container.persistentStoreCoordinator.addPersistentStore(ofType: NSBinaryStoreType, configurationName: nil, at: url, options: nil)
            result = self.save()
            try self.container.persistentStoreCoordinator.remove(store)
        } catch {
            let nserror = error as NSError
            NSApplication.shared.presentError(nserror)
        }
        
        return result
    }
    
    func loadDataFile<T>(from url: URL, request: NSFetchRequest<T>) -> [T]? {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.container.managedObjectModel)
        do {
            // TODO: Set options
            try coordinator.addPersistentStore(ofType: NSBinaryStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            let nserror = error as NSError
            NSApplication.shared.presentError(nserror)

            return nil
        }

        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        
        do {
            return try context.fetch(request)
        } catch {
            let nserror = error as NSError
            NSApplication.shared.presentError(nserror)
        }

        return nil
    }

    // MARK: - ControllerData
    
    func createControllerData(type: JoyCon.ControllerType) -> ControllerData {
        let controller = ControllerData(context: self.container.viewContext)
        controller.appConfigs = []
        controller.defaultConfig = self.createKeyConfig(type: type)
        
        return controller
    }
    
    func getControllerData(controller: JoyConSwift.Controller) -> ControllerData {
        let serialID = controller.serialID
        let context = self.container.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ControllerData")
        request.predicate = NSPredicate(format: "serialID == %@", serialID)

        do {
            let result = try context.fetch(request) as! [ControllerData]
            if result.count > 0 {
                return result[0]
            }
        } catch {
            fatalError("Failed to fetch ControllerData: \(error)")
        }

        let controller = self.createControllerData(type: controller.type)
        controller.serialID = serialID
        
        return controller
    }
    
    // MARK: - AppConfig
    
    func createAppConfig(type: JoyCon.ControllerType) -> AppConfig {
        let appConfig = AppConfig(context: self.container.viewContext)
        appConfig.app = self.createAppData()
        appConfig.config = self.createKeyConfig(type: type)

        return appConfig
    }

    // MARK: - AppData

    func createAppData() -> AppData {
        let appData = AppData(context: self.container.viewContext)

        return appData
    }

    // MARK: - KeyConfig

    func createKeyConfig(type: JoyCon.ControllerType) -> KeyConfig {
        let keyConfig = KeyConfig(context: self.container.viewContext)
        
        if type == .JoyConL || type == .ProController {
            keyConfig.leftStick = self.createStickConfig()
        }
        if type == .JoyConR || type == .ProController {
            keyConfig.rightStick = self.createStickConfig()
        }
        
        keyConfig.keyMaps = []
        
        return keyConfig
    }

    // MARK: - KeyMap

    func createKeyMap() -> KeyMap {
        let keyMap = KeyMap(context: self.container.viewContext)
        
        return keyMap
    }
    
    // MARK: - StickConfig
    
    func createStickConfig() -> StickConfig {
        let stickConfig = StickConfig(context: self.container.viewContext)

        stickConfig.speed = 10.0
        stickConfig.type = StickType.Mouse.rawValue

        let left = self.createKeyMap()
        left.button = StickDirection.Left.rawValue
        stickConfig.addToKeyMaps(left)

        let right = self.createKeyMap()
        right.button = StickDirection.Right.rawValue
        stickConfig.addToKeyMaps(right)

        let up = self.createKeyMap()
        up.button = StickDirection.Up.rawValue
        stickConfig.addToKeyMaps(up)

        let down = self.createKeyMap()
        down.button = StickDirection.Down.rawValue
        stickConfig.addToKeyMaps(down)
        
        return stickConfig
    }
    
    // MARK: - Common
    
    func delete(_ object: NSManagedObject) {
        self.container.viewContext.delete(object)
    }
}
