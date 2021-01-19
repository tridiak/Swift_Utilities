//
//  Misc.swift
//  Swift-Utilities
//
//  Created by tridiak on 9/12/18.
//  Copyright © 2018 tridiak. All rights reserved.
//

import Foundation


func RndBool() -> Bool {
	return arc4random() % 2 == 1 ? true : false
}
