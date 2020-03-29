//
//  ViewController+NSCollectionViewDelegate.swift
//  JoyKeyMapper
//
//  Created by magicien on 2019/07/15.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import AppKit

let connected = NSLocalizedString("Connected", comment: "Connected")

extension ViewController: NSCollectionViewDelegate, NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        let controllers = self.appDelegate?.controllers ?? []

        return controllers.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ControllerViewItem"), for: indexPath)

        guard let controllerItem = item as? ControllerViewItem else { return item }
        let index = indexPath.item
        guard let controllers = self.appDelegate?.controllers else { return item }
        guard controllers.count > index else { return item }
        let controller = controllers[index]

        controllerItem.iconView.image = controller.icon
        controllerItem.controller = controller
        controllerItem.label.stringValue = controller.controller != nil ? connected : ""
        
        return controllerItem
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let index = indexPaths.first?.item else {
            self.selectedController = nil
            return
        }
        guard let controllers = self.appDelegate?.controllers else {
            self.selectedController = nil
            return
        }
        guard controllers.count > index else {
            self.selectedController = nil
            return
        }
        self.selectedController = controllers[index]
    }
    
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        self.selectedController = nil
    }
}
