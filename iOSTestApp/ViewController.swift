//
//  ViewController.swift
//  iOSTestApp
//
//  Created by tridiak on 29/06/22.
//  Copyright © 2022 tridiak. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		
		
	}


	@IBAction func pushBtn(_ sender: Any) {
//		YesNoAlert(message: "Hello", info: "Info", title: "App", parentController: self) { FLAG in
//			print(FLAG)
//		}
		
		OKAlert(message: "Hello", info: "Info", title: "App", parentController: self)
		
	}
}

