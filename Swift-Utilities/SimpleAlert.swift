//
//  SimpleAlert.swift
//  SkillAlloc
//
//  Created by tridiak on 16/03/19.
//  Copyright © 2019 tridiak. All rights reserved.
//

import Cocoa

//---------------------------------------
// MARK:-

//func printnl(_ items: Any...) {
//	print(items, terminator:"")
//	}

#if os(iOS)

func TopController() -> UIViewController? {
	var C : UIViewController? = UIApplication.shared.delegate?.window??.rootViewController
	if C == nil { return nil }
	while C!.presentedViewController != nil {
		C = C!.presentedViewController
	}
	return C
}

#endif

func OKAlert(message : String, info : String, title: String) {
#if os(OSX)
	let alert = NSAlert.init()
	alert.messageText = message;
	alert.informativeText = info
	alert.window.title = title
	alert.runModal()
#elseif os(iOS)
	let alert = UIAlertController.init(title: message, message: info, preferredStyle: UIAlertControllerStyle.alert)
	alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (act) in
		TopController()!.dismiss(animated: true, completion: nil)
	}))
	
	TopController()?.present(alert, animated: true, completion: nil)
#endif
	}

func BlabError(error : NSError, title: String) {
#if os(OSX)
	let alert = NSAlert.init(error: error)
	alert.window.title = title
	alert.runModal()
#elseif os(iOS)
	OKAlert(message: "", info: error.localizedDescription)
#endif
	}

// Returns false for cancel, true for OK
func YesNoAlert(message : String, info : String, title: String) -> Bool {
#if os(OSX)
	let alert = NSAlert.init()
	alert.messageText = message;
	alert.informativeText = info
	alert.window.title = title
	alert.addButton(withTitle: "Cancel")
	alert.addButton(withTitle: "OK")
	
	return alert.runModal() == .alertSecondButtonReturn
#else
// TEST
	var b = false
	let alert = UIAlertController.init(title: message, message: info, preferredStyle: UIAlertControllerStyle.alert)
	alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (act) in
		TopController()!.dismiss(animated: true, completion: nil)
	}))
	alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (act) in
		TopController()!.dismiss(animated: true, completion: nil)
		b = true
	}))
	
	return b
#endif
}
