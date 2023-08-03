//
//  SimpleAlert.swift
//  SkillAlloc
//
//  Created by tridiak on 16/03/19.
//  Copyright © 2019 tridiak. All rights reserved.
//

#if os(OSX)
import Cocoa
#elseif os(iOS)
import UIKit
#else
#error("Platform not supported")
#endif

//---------------------------------------
// MARK:-


#if os(OSX)

/// Display Ok alert
/// - Parameters:
///   - message: General message
///   - info: Detailed Information
///   - title: Title of alert
///   - parent: Modal if nil otherwise sheet
func OKAlert(message : String, info : String, title: String, parent: NSWindow?) {
	let alert = NSAlert()
	alert.messageText = message
	alert.informativeText = info
	alert.alertStyle = .informational
	alert.window.title = title
	
	if let window = parent {
		alert.beginSheetModal(for: window)
	}
	else {
		alert.runModal()
	}
}
#elseif os(iOS)
/// Display Ok alert
/// - Parameters:
///   - message: General message
///   - info: Detailed Information
///   - title: Ignored
///   - parent: Parent view controller.
func OKAlert(message : String, info : String, title: String, parent: UIViewController) {
	let ctrl = UIAlertController(title: message, message: info, preferredStyle: .alert)
	ctrl.addAction(UIAlertAction(title: "OK", style: .default) )
//	if let parent = parent as? UIViewController {
		parent.present(ctrl, animated: true)
//	}
}
#endif

#if os(OSX)

/// Display Ok/Cancel alert
/// - Parameters:
///   - message: General message
///   - info: Detailed Information
///   - title: Title of alert
///   - parent: Modal if nil otherwise sheet
///   - action: Callback called when alert closed. OK = true, Cancel = false
func YesNoAlert(message : String, info : String, title: String, parent: NSWindow?, action: @escaping (Bool) ->()) {
	let alert = NSAlert()
	alert.messageText = message
	alert.informativeText = info
	alert.alertStyle = .informational
	alert.window.title = title
	alert.addButton(withTitle: "OK")
	alert.addButton(withTitle: "Cancel")
	
	if let window = parent {
		alert.beginSheetModal(for: window) { RESP in
			action(RESP == .alertFirstButtonReturn)
		}
	}
	else {
		let res = alert.runModal()
		action(res == .alertFirstButtonReturn)
	}
}
#elseif os(iOS)

/// Display Ok/Cancel alert
/// - Parameters:
///   - message: General message
///   - info: Detailed Information
///   - title: Ignored
///   - parent: Parent view controller.
///   - action: Callback called when alert closed. OK = true, Cancel = false
func YesNoAlert(message : String, info : String, title: String, parent: UIViewController, action: @escaping (Bool) ->()) {
	let ctrl = UIAlertController(title: message, message: info, preferredStyle: .alert)
	ctrl.addAction(UIAlertAction(title: "OK", style: .default, handler: { ACT in
		action(true)
	}))
	ctrl.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { ACT in
		action(false)
	}))
	
	parent.present(ctrl, animated: true)
}
#endif
