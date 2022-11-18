//
//  ViewController.swift
//  SwiftUtilityApp
//
//  Created by tridiak on 28/06/22.
//  Copyright © 2022 tridiak. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	@IBAction func pushBtn(_ sender: Any) {
//		YesNoAlert(message: "Message", info: "Info", title: "App", parent: self.view.window) { RES in
//			print(RES)
//		}
		
		OKAlert(message: "Message", info: "Info", title: "App", parent: self.view.window)
	}
	
}

