//
//  KeyConfigComboBox.swift
//  JoyConMapper
//
//  Created by magicien on 2019/07/29.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import AppKit
import InputMethodKit

protocol KeyConfigComboBoxDelegate {
    func setKeyCode(_ keyCode: UInt16)
}

let keyCodeList: [Int] = [
    kVK_ISO_Section,
    kVK_Return,
    kVK_Tab,
    kVK_Space,
    kVK_Delete,
    kVK_Escape,
    kVK_CapsLock,
    kVK_RightShift,
    kVK_RightOption,
    kVK_RightControl,
    kVK_F1,
    kVK_F2,
    kVK_F3,
    kVK_F4,
    kVK_F5,
    kVK_F6,
    kVK_F7,
    kVK_F8,
    kVK_F9,
    kVK_F10,
    kVK_F11,
    kVK_F12,
    kVK_F13,
    kVK_F14,
    kVK_F15,
    kVK_F16,
    kVK_F17,
    kVK_F18,
    kVK_F19,
    kVK_F20,
    kVK_ANSI_Keypad0,
    kVK_ANSI_Keypad1,
    kVK_ANSI_Keypad2,
    kVK_ANSI_Keypad3,
    kVK_ANSI_Keypad4,
    kVK_ANSI_Keypad5,
    kVK_ANSI_Keypad6,
    kVK_ANSI_Keypad7,
    kVK_ANSI_Keypad8,
    kVK_ANSI_Keypad9,
    kVK_ANSI_KeypadMultiply,
    kVK_ANSI_KeypadPlus,
    kVK_ANSI_KeypadClear,
    kVK_JIS_KeypadComma,
    kVK_ANSI_KeypadEnter,
    kVK_ANSI_KeypadMinus,
    kVK_ANSI_KeypadDivide,
    kVK_ANSI_KeypadEquals,
    kVK_ANSI_KeypadDecimal,
    kVK_VolumeUp,
    kVK_VolumeDown,
    kVK_Mute,
    kVK_JIS_Yen,
    kVK_JIS_Underscore,
    kVK_JIS_Eisu,
    kVK_JIS_Kana,
    kVK_Help,
    kVK_Home,
    kVK_PageUp,
    kVK_PageDown,
    kVK_ForwardDelete,
    kVK_End,
    kVK_LeftArrow,
    kVK_RightArrow,
    kVK_DownArrow,
    kVK_UpArrow
]

let keyCells: [NSComboBoxCell] = {
    return keyCodeList.map {
        let keyName = getKeyName(keyCode: UInt16($0))
        return NSComboBoxCell(textCell: keyName)
    }
}()

class KeyConfigComboBox: NSComboBox {
    var configDelegate: KeyConfigComboBoxDelegate?
    
    var monitor: Any?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)        
        self.addItems(withObjectValues: keyCells)
    }
    
    override func becomeFirstResponder() -> Bool {
        self.stringValue = ""
        self.monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { [weak self] event in
            guard let _self = self else { return event }

            _self.window?.makeFirstResponder(nil)
            _self.configDelegate?.setKeyCode(event.keyCode)
            if let monitor = _self.monitor {
                _self.monitor = nil
                NSEvent.removeMonitor(monitor)
            }
            return nil
        })
        return true
    }
}
