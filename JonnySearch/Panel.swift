//
//  Panel.swift
//  JonnySearch
//
//  Created by Jonny on 3/31/17.
//  Copyright © 2017 Junyu Kuang <lightscreen.app@gmail.com>. All rights reserved.
//

import Cocoa

class Panel: NSPanel {
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
	
	override var acceptsFirstResponder: Bool {
		return true
	}
	
	override func becomeFirstResponder() -> Bool {
		print(type(of: self), #function)
		return super.becomeFirstResponder()
	}
	
	override func resignFirstResponder() -> Bool {
		print(type(of: self), #function)
		return super.resignFirstResponder()
	}
}
