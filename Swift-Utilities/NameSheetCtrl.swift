//
//  NameSheetCtrl.swift
//  SpellTheme
//
//  Created by tridiak on 22/02/21.
//

import Cocoa

class NameSheetCtrl: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
	//------------------------------------------------------
	// MARK:-
	
	@IBOutlet var nameEdit : NSTextField!
	
	private func DoNameWindow(doneProc:@escaping (String?) -> Void) {
		parentWindow.beginSheet(self.window!) { (RESP) in
			if RESP == .abort {
				doneProc(nil)
			}
			else {
				doneProc(self.nameEdit.stringValue)
			}
		}
	}
	
	@IBAction func NameOK(_ sender: NSButton) {
		parentWindow.endSheet(self.window!, returnCode: .continue)
	}
	
	@IBAction func NameCancel(_ sender: NSButton) {
		parentWindow.endSheet(self.window!, returnCode: .abort)
	}
	
	private static var windowCtrl : NameSheetCtrl!
	private var parentWindow : NSWindow! = nil
	
	static func ShowNameWindow(parent: NSWindow, doneProc:@escaping (String?) -> Void) {
		if windowCtrl == nil {
			windowCtrl = NameSheetCtrl(windowNibName: NSNib.Name("NameSheetCtrl"))
		}
		
		windowCtrl.parentWindow = parent
		windowCtrl.DoNameWindow(doneProc: doneProc)
	}
}

