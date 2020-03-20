//
//  ViewController.swift
//  JoyConMapper
//
//  Created by magicien on 2019/07/14.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import AppKit
import InputMethodKit
import JoyConSwift

class ViewController: NSViewController {
    
    @IBOutlet weak var controllerCollectionView: NSCollectionView!
    @IBOutlet weak var appTableView: NSTableView!
    @IBOutlet weak var appAddRemoveButton: NSSegmentedControl!
    @IBOutlet weak var configTableView: NSOutlineView!
    
    var appDelegate: AppDelegate? {
        return NSApplication.shared.delegate as? AppDelegate
    }
    var selectedController: GameController? {
        didSet {
            self.appTableView.reloadData()
            self.configTableView.reloadData()
            self.updateAppAddRemoveButtonState()
        }
    }
    var selectedControllerData: ControllerData? {
        return self.selectedController?.data
    }
    var selectedAppConfig: AppConfig? {
        guard let data = self.selectedControllerData else {
            return nil
        }
        let row = self.appTableView.selectedRow
        if row < 1 {
            return nil
        }
        return data.appConfigs?[row - 1] as? AppConfig
    }
    var selectedKeyConfig: KeyConfig? {
        if self.appTableView.selectedRow < 0 {
            return nil
        }
        return self.selectedAppConfig?.config ?? self.selectedControllerData?.defaultConfig
    }
    var keyDownHandler: Any?

    override func viewDidLoad() {
        super.viewDidLoad()

        if self.controllerCollectionView == nil { return }
        
        self.controllerCollectionView.delegate = self
        self.controllerCollectionView.dataSource = self
        
        self.appTableView.delegate = self
        self.appTableView.dataSource = self
        
        self.configTableView.delegate = self
        self.configTableView.dataSource = self
        
        self.updateAppAddRemoveButtonState()

        NotificationCenter.default.addObserver(self, selector: #selector(controllerAdded), name: .controllerAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(controllerRemoved), name: .controllerRemoved, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(controllerConnected), name: .controllerConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(controllerDisconnected), name: .controllerDisconnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(controllerIconChanged), name: .controllerIconChanged, object: nil)
    }
    
    override func viewDidDisappear() {

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK: - Apps
    
    @IBAction func clickAppSegmentButton(_ sender: NSSegmentedControl) {
        let selectedSegment = sender.selectedSegment
        
        if selectedSegment == 0 {
            self.addApp()
        } else if selectedSegment == 1 {
            self.removeApp()
        }
    }
    
    func updateAppAddRemoveButtonState() {
        if self.selectedController == nil {
            self.appAddRemoveButton.setEnabled(false, forSegment: 0)
            self.appAddRemoveButton.setEnabled(false, forSegment: 1)
        } else if self.appTableView.selectedRow < 1 {
            self.appAddRemoveButton.setEnabled(true, forSegment: 0)
            self.appAddRemoveButton.setEnabled(false, forSegment: 1)
        } else {
            self.appAddRemoveButton.setEnabled(true, forSegment: 0)
            self.appAddRemoveButton.setEnabled(true, forSegment: 1)
        }        
    }
    
    func addApp() {
        guard let controller = self.selectedController else { return }
        
        let panel = NSOpenPanel()
        panel.message = NSLocalizedString("Choose an app to add", comment: "Choosing app message")
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.canChooseFiles = true
        panel.allowedFileTypes = ["app"]
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.begin { [weak self] response in
            if response == .OK {
                guard let url = panel.url else { return }
                controller.addApp(url: url)
                self?.appTableView.reloadData()
            }
        }
    }
    
    func removeApp() {
        guard let controller = self.selectedController else { return }
        guard let appConfig = self.selectedAppConfig else { return }
        let appName = self.convertAppName(appConfig.app?.displayName)
        
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Do you really want to delete the settings for \(appName)?"
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "OK")
        let result = alert.runModal()
        
        if result == .alertSecondButtonReturn {
            controller.removeApp(appConfig)
            self.appTableView.reloadData()
            self.configTableView.reloadData()
        }
    }
    
    // MARK: - Controllers
    
    @objc func controllerAdded() {
        DispatchQueue.main.async { [weak self] in
            self?.controllerCollectionView.reloadData()
        }
    }
    
    @objc func controllerConnected() {
        DispatchQueue.main.async { [weak self] in
            self?.controllerCollectionView.reloadData()
        }
    }
    
    @objc func controllerDisconnected() {
        DispatchQueue.main.async { [weak self] in
            self?.controllerCollectionView.reloadData()
        }
    }
    
    @objc func controllerRemoved(_ notification: NSNotification) {
        guard let gameController = notification.object as? GameController else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let _self = self else { return }
            let numItems = _self.controllerCollectionView.numberOfItems(inSection: 0)
            for i in 0..<numItems {
                if let item = self?.controllerCollectionView.item(at: i) as? ControllerViewItem {
                    if item.controller === gameController {
                        self?.controllerCollectionView.deselectAll(nil)
                    }
                }
            }
            self?.controllerCollectionView.reloadData()
        }
    }
    
    @objc func controllerIconChanged(_ notification: NSNotification) {
        guard let gameController = notification.object as? GameController else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.controllerCollectionView.reloadData()
        }
    }
    
    // MARK: - Options
    
    @IBAction func didPushOptions(_ sender: NSButton) {
        guard let controller = self.storyboard?.instantiateController(withIdentifier: "AppSettingsViewController") as? AppSettingsViewController else { return }
        
        self.presentAsSheet(controller)
    }
}
