//
//  Events.swift
//  JonnySearch
//
//  Created by Jonny on 12/24/17.
//  Copyright © 2017 Junyu Kuang <lightscreen.app@gmail.com>. All rights reserved.
//

import AppKit
import Carbon

class KillSourceKitServiceEvent: NSEvent {
    
    override var modifierFlags: NSEvent.ModifierFlags {
        return [.shift, .command]
    }
    
    override var keyCode: UInt16 {
        return UInt16(kVK_ANSI_X)
    }
}

class PasteShortcutEvent: NSEvent {
    
    override var modifierFlags: NSEvent.ModifierFlags {
        return [.shift, .command]
    }
    
    override var keyCode: UInt16 {
        return UInt16(kVK_ANSI_V)
    }
}

class AirDropShortcutEvent: NSEvent {
    
    override var modifierFlags: NSEvent.ModifierFlags {
        return [.shift, .command]
    }
    
    override var keyCode: UInt16 {
        return UInt16(kVK_ANSI_R)
    }
}
