//
//  SpecialKeyName.swift
//  JoyKeyMapper
//
//  Created by magicien on 2019/07/25.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import Foundation
import InputMethodKit

let SpecialKeyName: [Int:String] = [
    kVK_ISO_Section: "Section",
    kVK_Return: "Return",
    kVK_Tab: "Tab",
    kVK_Space: "Space",
    kVK_Delete: "Delete",
    kVK_Escape: "Escape",
    kVK_Command: "⌘",
    kVK_Shift: "⇧",
    kVK_CapsLock: "CapsLock",
    kVK_Option: "⌥",
    kVK_Control: "⌃",
    kVK_RightShift: "Right⇧",
    kVK_RightOption: "Right⌥",
    kVK_RightControl: "Right⌃",
    kVK_Function: "fn",
    kVK_F1: "F1",
    kVK_F2: "F2",
    kVK_F3: "F3",
    kVK_F4: "F4",
    kVK_F5: "F5",
    kVK_F6: "F6",
    kVK_F7: "F7",
    kVK_F8: "F8",
    kVK_F9: "F9",
    kVK_F10: "F10",
    kVK_F11: "F11",
    kVK_F12: "F12",
    kVK_F13: "F13",
    kVK_F14: "F14",
    kVK_F15: "F15",
    kVK_F16: "F16",
    kVK_F17: "F17",
    kVK_F18: "F18",
    kVK_F19: "F19",
    kVK_F20: "F20",
    kVK_ANSI_Keypad0: "Keypad 0",
    kVK_ANSI_Keypad1: "Keypad 1",
    kVK_ANSI_Keypad2: "Keypad 2",
    kVK_ANSI_Keypad3: "Keypad 3",
    kVK_ANSI_Keypad4: "Keypad 4",
    kVK_ANSI_Keypad5: "Keypad 5",
    kVK_ANSI_Keypad6: "Keypad 6",
    kVK_ANSI_Keypad7: "Keypad 7",
    kVK_ANSI_Keypad8: "Keypad 8",
    kVK_ANSI_Keypad9: "Keypad 9",
    kVK_ANSI_KeypadMultiply: "Keypad *",
    kVK_ANSI_KeypadPlus: "Keypad +",
    kVK_ANSI_KeypadClear: "Keypad Clear",
    kVK_JIS_KeypadComma: "Keypad ,",
    kVK_ANSI_KeypadEnter: "Keypad Enter",
    kVK_ANSI_KeypadMinus: "Keypad -",
    kVK_ANSI_KeypadDivide: "Keypad /",
    kVK_ANSI_KeypadEquals: "Keypad =",
    kVK_ANSI_KeypadDecimal: "Keypad Decimal",
    kVK_VolumeUp: "VolumeUp",
    kVK_VolumeDown: "VolumeDown",
    kVK_Mute: "Mute",
    kVK_JIS_Yen: "¥",
    kVK_JIS_Underscore: "_",
    kVK_JIS_Eisu: "Eisu",
    kVK_JIS_Kana: "Kana",
    kVK_Help: "Help",
    kVK_Home: "Home",
    kVK_PageUp: "PageUp",
    kVK_PageDown: "PageDown",
    kVK_ForwardDelete: "ForwardDelete",
    kVK_End: "End",
    kVK_LeftArrow: "←",
    kVK_RightArrow: "→",
    kVK_DownArrow: "↓",
    kVK_UpArrow: "↑"
]

let LocalizedSpecialKeyName = SpecialKeyName.mapValues {
    NSLocalizedString($0, comment: $0)
}