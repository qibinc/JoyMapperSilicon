//
//  SpecialKeyName.swift
//  JoyKeyMapper
//
//  Created by magicien on 2019/07/25.
//  Copyright © 2019 DarkHorse. All rights reserved.
//

import Foundation
import InputMethodKit

let SpecialKey_BaseValue = 0x7000
let SpecialKey_BrightnessUp = SpecialKey_BaseValue + Int(NX_KEYTYPE_BRIGHTNESS_UP)
let SpecialKey_BrightnessDown = SpecialKey_BaseValue + Int(NX_KEYTYPE_BRIGHTNESS_DOWN)
let SpecialKey_Power = SpecialKey_BaseValue + Int(NX_POWER_KEY)
let SpecialKey_NumLock = SpecialKey_BaseValue + Int(NX_KEYTYPE_NUM_LOCK)
let SpecialKey_Play = SpecialKey_BaseValue + Int(NX_KEYTYPE_PLAY)
let SpecialKey_Next = SpecialKey_BaseValue + Int(NX_KEYTYPE_NEXT)
let SpecialKey_Previous = SpecialKey_BaseValue + Int(NX_KEYTYPE_PREVIOUS)
let SpecialKey_Fast = SpecialKey_BaseValue + Int(NX_KEYTYPE_FAST)
let SpecialKey_Rewind = SpecialKey_BaseValue + Int(NX_KEYTYPE_REWIND)

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
    kVK_UpArrow: "↑",
    SpecialKey_BrightnessUp: "BrightnessUp",
    SpecialKey_BrightnessDown: "BrightnessDown",
    SpecialKey_NumLock: "NumLock",
    SpecialKey_Play: "Play",
    SpecialKey_Next: "Next",
    SpecialKey_Previous: "Previous",
    SpecialKey_Fast: "Fast",
    SpecialKey_Rewind: "Rewind"
]

let LocalizedSpecialKeyName = SpecialKeyName.mapValues {
    NSLocalizedString($0, comment: $0)
}

let systemDefinedKey: [Int: Int32] = [
    kVK_VolumeUp: NX_KEYTYPE_SOUND_UP,
    kVK_VolumeDown: NX_KEYTYPE_SOUND_DOWN,
    SpecialKey_BrightnessUp: NX_KEYTYPE_BRIGHTNESS_UP,
    SpecialKey_BrightnessDown: NX_KEYTYPE_BRIGHTNESS_DOWN,
    // kVK_CapsLock: NX_KEYTYPE_CAPS_LOCK,
    // kVK_Help: NX_KEYTYPE_HELP,
    // NX_POWER_KEY
    kVK_Mute: NX_KEYTYPE_MUTE,
    // NX_UP_ARROW_KEY
    // NX_DOWN_ARROW_KEY
    // NX_KEYTYPE_NUM_LOCK,
    // NX_KEYTYPE_CONTRAST_UP
    // NX_KEYTYPE_CONTRAST_DOWN
    // NX_KEYTYPE_LAUNCH_PANEL
    // NX_KEYTYPE_EJECT
    // NX_KEYTYPE_VIDMIRROR
    SpecialKey_Play: NX_KEYTYPE_PLAY,
    SpecialKey_Next: NX_KEYTYPE_NEXT,
    SpecialKey_Previous: NX_KEYTYPE_PREVIOUS,
    SpecialKey_Fast: NX_KEYTYPE_FAST,
    SpecialKey_Rewind: NX_KEYTYPE_REWIND
]
