//
//  PathClass.swift
//  Swift-Utilities
//
//  Created by tridiak on 8/12/18.
//  Copyright © 2018 tridiak. All rights reserved.
//

import Foundation

class PathClass : CustomDebugStringConvertible {
	
	enum PathClassEx : Error {
		case dirMarkerIsDotEx
	}
	
	//----------------------------------
	
	private(set) var path : String
	private(set) var dirMarker : Character
	
	init?(path P : String, marker : Character = "/") {
		if marker == "\0" { return nil }
		
		path = P
		dirMarker = marker
	}
	
	var debugDescription: String { return path }
	//----------------------------------------------
	
	// Appends component marker if it doesn't exist
	func AppendDirMarker() {
		if path.isEmpty { path = String(dirMarker) }
		else {
			if path.last! != dirMarker { path.append(dirMarker) }
		}
	}
	
	// Removes component marker from end if it exists
	func RemoveDirMarker() {
		if !path.isEmpty {
			if path.last! == dirMarker { path.removeLast() }
		}
	}
	
	// First char is not component marker
	var isRelative : Bool {
		if path.isEmpty { return true }
		else  { return path.first! != dirMarker }
	}
	
	// Last character is the component marker
	func LastCharIsMarker() -> Bool {
		if path.isEmpty { return false }
		return path.last! == dirMarker
	}
	
	// First character is the component marker
	func FirstCharIsMarker() -> Bool {
		if path.isEmpty { return false }
		return path.first! == dirMarker
	}
	
	// Prepends passed string to path.
	// Will add or remove component marker as needed
	func Prepend(path component: String) {
		if component.isEmpty { return }
		
		if path.isEmpty {
			path = component
			return
		}
		
		let lastChar = component.last!
		if lastChar == dirMarker {
			if FirstCharIsMarker() {
				path.removeFirst()
				path = component + path
			}
		}
		else {
			if !FirstCharIsMarker() {
				path.insert(dirMarker, at: path.startIndex)
			}
			
			path = component + path
		}
	} // prepend
	
	// Add passed path to path. Will add or remove component marker as needed
	func Add(path component: String) {
		if component.isEmpty { return }
		
		if path.isEmpty {
			path = component
			return
		}
		
		if component.first! == dirMarker && path.last! == dirMarker { RemoveDirMarker() }
		else if component.first! != dirMarker { AppendDirMarker() }
		path += component
	}
	
	// Adds suffix to path.
	// 	Suffix = "txt"
	// /A/Path/	-> /A/Path/.txt
	// /A/Path	-> /A/Path.txt
	// /A/Path. -> /A/Path.txt
	func Add(suffix : String) {
		if !path.isEmpty {
			if path.last! != "." { path += "." }
			path += suffix
		}
		else {
			path = "." + suffix
		}
	}
	
	// Removes suffix from path AFTER the last component marker.
	// /A/Path.txt	-> /A/Path
	// /A/Path.txt/B	-> /A/Path.txt/B
	// An exception will be thrown if the component mark is '.'
	func RemoveSuffix() throws {
		if dirMarker == "." { throw PathClassEx.dirMarkerIsDotEx }
		
		guard let dotIdx = path.range(of: ".", options: .backwards, range: nil, locale: nil) else { return }
		if path.range(of: String(dirMarker), options: .backwards,
					  range: dotIdx.upperBound..<path.endIndex, locale: nil) != nil {
			// dir marker is after last '.'
			return
			}
		
		path = String(path[..<dotIdx.lowerBound])
		
	}
	
	//
	func Components() -> [String] {
		return path.split(separator: dirMarker).ToStringArray()
	}
	
	// Removes all characters after last component marker and the marker itself.
	func RemoveLastComponent() {
		if path.isEmpty { return }
		
		if let idx = path.range(of: String(dirMarker), options: .backwards, range: nil, locale: nil) {
			// FIX : idx.upperBound -> idx.lowerBound
			path.removeSubrange(idx.lowerBound..<path.endIndex)
		}
		else {
			path = ""
		}
	}
	
	// Change the component marker and convert path's markers to such.
	// Existing characters the same as the new marker in the path will
	// not be converted.
	// 'A/B/C:s:3/D'. newMarker = ':' -> 'A:B:C:s:3:D'.
	func ConvertMarkers(marker: Character) {
		if marker == dirMarker { return }
		
		path.ReplaceAllM(chars: String(dirMarker), with: marker)
		
		dirMarker = marker
	}
	
	// Change the directory marker and convert path's markers to such.
	// Existing characters the same as the new marker will be converted to the
	// old marker.
	// 'A/B/C:s:3/D'. newMarker = ':' -> 'A:B:C/s/3:D'.
	func SwapDirMarkers(marker: Character) {
		if marker == dirMarker { return }
		
		var s = ""
		for c in path {
			if c == dirMarker { s.append(marker) }
			else if c == marker { s.append(dirMarker) }
			else { s.append(c) }
		}
		
		path = s
		
		dirMarker = marker
	}
	
	// Change the directory marker. The path's directory markers are not changed.
	// 'A/B/C:s:3/D'. newMarker = ':' -> 'A/B/C:s:3/D'.
	func ChangeDir(marker: Character) {
		dirMarker = marker
	}
	
	//----------------------------------------------
	// MARK:- Operators

	static func == (LHS : PathClass, RHS : PathClass) -> Bool {
		return LHS.path == RHS.path
	}

	static func != (LHS : PathClass, RHS : PathClass) -> Bool {
		return LHS.path != RHS.path
	}
	
	static func < (LHS : PathClass, RHS : PathClass) -> Bool {
		return LHS.path < RHS.path
	}
	
	/// Removes last component. Calls RemoveLastComponent()
	static postfix func -- (path : PathClass) {
		path.RemoveLastComponent()
	}
	
	/// Returns path component idx
	subscript(idx : UInt) -> String? {
		if path.isEmpty { return nil }
		let C = Components()
		if idx >= C.count { return nil }
		return C[Int(idx)]
	}
}



