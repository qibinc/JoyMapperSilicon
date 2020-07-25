//
//  Utils.swift
//  JoyKeyMapper
//
//  Created by magicien on 2019/07/29.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import Foundation
import InputMethodKit

let mouseButtonNames: [String] = [
    "Left Click",
    "Right Click",
    "Center Click"
]
let localizedMouseButtonNames = mouseButtonNames.map {
    NSLocalizedString($0, comment: $0)
}
let none = NSLocalizedString("none", comment: "none")

func convertModifierKeys(_ modifiers: NSEvent.ModifierFlags) -> String {
    var keyName = ""
    if modifiers.contains(.control) {
        keyName += NSLocalizedString("⌃", comment: "⌃")
    }
    if modifiers.contains(.option) {
        keyName += NSLocalizedString("⌥", comment: "⌥")
    }
    if modifiers.contains(.shift) {
        keyName += NSLocalizedString("⇧", comment: "⇧")
    }
    if modifiers.contains(.command) {
        keyName += NSLocalizedString("⌘", comment: "⌘")
    }
    return keyName
}

func convertKeyName(keyMap: KeyMap?) -> String {
    guard let map = keyMap else { return none }

    let modifiers = convertModifierKeys(NSEvent.ModifierFlags(rawValue: UInt(map.modifiers)))

    if map.keyCode >= 0 {
        let keyName = getKeyName(keyCode: UInt16(map.keyCode))
        return "\(modifiers)\(keyName)"
    }
    
    if map.mouseButton >= 0 {
        let buttonName = localizedMouseButtonNames[Int(map.mouseButton)]
        if modifiers != "" {
            return "\(modifiers) + \(buttonName)"
        }
        return buttonName
    }
    
    return none
}

func getKeyName(keyCode: UInt16) -> String {
    if let specialKey = LocalizedSpecialKeyName[Int(keyCode)] {
        return specialKey
    }
    let maxNameLength = 4
    var nameBuffer = [UniChar](repeating: 0, count : maxNameLength)
    var nameLength = 0
    var deadKeys: UInt32 = 0
    let keyboardType = UInt32(LMGetKbdType())
    let source = TISCopyCurrentKeyboardLayoutInputSource().takeRetainedValue()
    guard let ptr = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData) else {
        return none
    }
    let layoutData = Unmanaged<CFData>.fromOpaque(ptr).takeUnretainedValue() as Data
    layoutData.withUnsafeBytes {
        guard let ptr = $0.baseAddress?.assumingMemoryBound(to: UCKeyboardLayout.self) else { return }
        UCKeyTranslate(ptr, keyCode, UInt16(kUCKeyActionDown),
                       0, keyboardType, UInt32(kUCKeyTranslateNoDeadKeysMask),
                       &deadKeys, maxNameLength, &nameLength, &nameBuffer)
    }
    let name = String(utf16CodeUnits: nameBuffer, count: nameLength)
    
    return name.uppercased()
}

/** Get the frontmost winodow ID. Currently not used. */
func getFrontmostWinodowNumber() -> Int? {
    let app = NSWorkspace.shared.frontmostApplication
    guard let pidInt32 = app?.processIdentifier else { return nil }
    let pid = Int64(pidInt32)
    guard let windowList = CGWindowListCopyWindowInfo(.optionAll, kCGNullWindowID) as? [NSDictionary] else { return nil }
    let window = windowList.first { ($0[kCGWindowOwnerPID] as? Int64 ?? -1) == pid }

    return window?[kCGWindowNumber] as? Int
}
