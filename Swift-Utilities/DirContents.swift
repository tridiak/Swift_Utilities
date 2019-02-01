//
//  DirContents.swift
//  Swift-Utilities
//
//  Created by tridiak on 9/12/18.
//  Copyright © 2018 tridiak. All rights reserved.
//

import Foundation

class DirContents : Sequence {
	
	func makeIterator() -> DCIterator {
		return DCIterator(DC: self, index: 0)
	}
	
	// Exceptions
	enum DirContentsEx : Error {
		case notADir
		case invalidPath
		case cannotAccessDir
	}
	
	// Directory path
	let path : PathClass
	
	// List of dir item names
	private(set) var names : [String] = []
	
	// See subscript
	var nameOrPathFlag : Bool = false
	
	// Constructor
	init?(path P : String) {
		if P.isEmpty { return nil }
		
		guard let R = PathClass(path: P) else { return nil }
		path = R
		
		path.RemoveDirMarker()
	}
	
	// Gather the contents of the directory.
	func Gather() throws {
		// Check path is a directory and exists
		var st = stat()
		
		var res : Int32 = 0
		
		res = stat(path.path, &st)
		
		if res != 0 { throw DirContentsEx.invalidPath }
		
		if (st.st_mode & S_IFMT) != S_IFDIR { throw DirContentsEx.notADir }
		
		names.removeAll()
		
		guard let dptr : UnsafeMutablePointer<DIR> = opendir(path.path) else { throw DirContentsEx.cannotAccessDir }
		
		var d : UnsafeMutablePointer<dirent>? = nil
		
		d = readdir(dptr)
		while (d != nil) {
			
			let name = withUnsafePointer(to: &d!.pointee.d_name) {
			$0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: d!.pointee.d_name)) {
				String(cString: $0)
				}
			}
			
			if name == "." || name == ".." {  }
			else {
				names.append(name)
			}
			
			d = readdir(dptr)
		}
		
		closedir(dptr)
		
	}
	
	/// Override if you want to change sorting algorithm
	func Sort() {
		names.sort { (A, B) -> Bool in
			return A < B
		}
	}
	
	// Three types of iteration
	//	subscript
	//	Iterate() func
	//	Iterator protocol
	
	// Subscript.
	// Returns full path or name only depending on nameOrPathFlag
	subscript(idx : Int) -> String? {
		if idx < 0 || idx >= names.count { return nil }
		
		if nameOrPathFlag { return path.path + "/" + names[idx] }
		return names[Int(idx)]
	}
	
	// Return true to stop iteration
	typealias IterBlock = (String) -> Bool
	
	// Iterate over names/paths.
	// Respects nameOrPathFlag
	func Iterate(block : IterBlock) {
		for namePath in self {
			if block(namePath) { break }
		}
	}
}

//------------------------------------------

// Respects 'nameOrPathFlag' flag of DirContents
public struct DCIterator : IteratorProtocol {
	let DC : DirContents
	var index : Int = 0
	
	public mutating func next() -> String? {
		let name = DC[index]
		
		index += 1
		return name
		
	}
	
	public typealias Element = String
	
}
