//
//  StickConfigCellView.swift
//  JoyKeyMapper
//
//  Created by magicien on 2019/08/07.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import AppKit

protocol StickConfigCellViewDelegate {
    func typeDidChange(_ sender: NSPopUpButton)
}

class StickConfigCellView: NSTableCellView {
    var typeButton: NSPopUpButton

    override init(frame frameRect: NSRect) {
        self.typeButton = NSPopUpButton(frame: frameRect)
        super.init(frame: frameRect)

        let mouse = NSLocalizedString("Mouse", comment: "Mouse")
        let key = NSLocalizedString("Key", comment: "Key")
        self.typeButton.addItems(withTitles: [mouse, key])

        self.addSubview(self.typeButton)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
