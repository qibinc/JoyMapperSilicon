//
//  ViewController+NSTableViewDelegate.swift
//  JoyKeyMapper
//
//  Created by magicien on 2019/07/21.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import AppKit
import JoyConSwift

let appNameColumnID = "appName"

extension ViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView === self.appTableView {
            return self.numRowsOfAppTableView()
        }
        
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView === self.appTableView {
            return self.viewForAppTable(column: tableColumn, row: row)
        }

        return nil
    }

    // MARK: - AppTableView
    
    func convertAppName(_ name: String?) -> String {
        guard var appName = name else { return "" }
        
        if appName.hasSuffix(".app") {
            appName.removeLast(4)
        }
        appName = appName.replacingOccurrences(of: "%20", with: " ")
        
        return appName
    }
    
    func numRowsOfAppTableView() -> Int {
        guard let controller = self.selectedController else { return 0 }
        
        let numApps = controller.data.appConfigs?.count ?? 0
        
        return numApps + 1
    }
    
    func viewForAppTable(column: NSTableColumn?, row: Int) -> NSView? {
        guard let controller = self.selectedController else { return nil }
        guard let col = column else { return nil }
        guard let newView = self.appTableView.makeView(withIdentifier: col.identifier, owner: self) as? AppCellView else { return nil }
        
        if row == 0 {
            newView.appIcon.image = NSImage(named: "GenericApplicationIcon")
            newView.appName.stringValue = "Default"
        } else {
            guard let appConfig = controller.data.appConfigs?[row - 1] as? AppConfig else { return nil }
            guard let appData = appConfig.app else { return nil }

            if let icon = appData.icon {
                newView.appIcon.image = NSImage(data: icon)
            } else {
                newView.appIcon.image = NSImage(named: "GenericApplicationIcon")
            }
            
            newView.appName.stringValue = self.convertAppName(appData.displayName)
        }
        
        return newView
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        self.updateAppAddRemoveButtonState()
        self.configTableView.reloadData()
    }
}
