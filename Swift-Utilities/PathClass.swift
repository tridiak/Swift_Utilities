//
//  PathClass.swift
//  Swift-Utilities
//
//  Created by tridiak on 8/12/18.
//  Copyright © 2018 tridiak. All rights reserved.
//

import Foundation

class PathClass : CustomDebugStringConvertible, Equatable {
	
	enum PathClassEx : Error {
		case dirMarkerIsDotEx
	}
	
	//----------------------------------
	
	private(set) var path : String
	private(set) var dirMarker : Character
	
	/// Will only return nil if dirMarker is null character.
	init?(path P : String, dirMarker : Character = "/") {
		if dirMarker == "\0" { return nil }
		
		path = P
		self.dirMarker = dirMarker
	}
	
	var debugDescription: String { return path }
	//----------------------------------------------
	
	// Appends component marker if it doesn't exist
	@discardableResult func AppendDirMarker() -> PathClass {
		if path.isEmpty { path = String(dirMarker) }
		else {
			if path.last! != dirMarker { path.append(dirMarker) }
		}
		
		return self
	}
	
	// Removes component marker from end if it exists
	@discardableResult func RemoveDirMarker() -> PathClass {
		if !path.isEmpty {
			if path.last! == dirMarker { path.removeLast() }
		}
		
		return self
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
	@discardableResult func Prepend(path component: String) -> PathClass {
		if component.isEmpty { return self }
		
		if path.isEmpty {
			path = component
			return self
		}
		
		let lastChar = component.last!
		if lastChar == dirMarker {
			if FirstCharIsMarker() {
				path.removeFirst()
				
			}
			path = component + path
		}
		else {
			if !FirstCharIsMarker() {
				path.insert(dirMarker, at: path.startIndex)
			}
			
			path = component + path
		}
		
		return self
	} // prepend
	
	// Add passed path to path. Will add or remove component marker as needed
	@discardableResult func Add(path component: String) -> PathClass {
		if component.isEmpty { return self }
		
		if path.isEmpty {
			path = component
			return self
		}
		
		if component.first! == dirMarker {
			if path.last! == dirMarker {
				RemoveDirMarker()
			}
		}
		else {
			AppendDirMarker()
		}
		
		path += component
		
		return self
	}
	
	// Adds suffix to path.
	// 	Suffix = "txt"
	// /A/Path/	-> /A/Path/.txt
	// /A/Path	-> /A/Path.txt
	// /A/Path. -> /A/Path.txt
	@discardableResult func Add(suffix : String) -> PathClass {
		if !path.isEmpty {
			if path.last! != "." { path += "." }
			path += suffix
		}
		else {
			path = "." + suffix
		}
		
		return self
	}
	
	// Removes suffix from path AFTER the last component marker.
	// /A/Path.txt	-> /A/Path
	// /A/Path.txt/B	-> /A/Path.txt/B
	// An exception will be thrown if the component mark is '.'
	@discardableResult func RemoveSuffix() throws -> PathClass {
		if dirMarker == "." { throw PathClassEx.dirMarkerIsDotEx }
		
		guard let p = path.StringBeforeLast(char: ".") else { return self }
		path = p
//		guard let dotIdx = path.range(of: ".", options: .backwards, range: nil, locale: nil) else { return }
//		if path.range(of: String(dirMarker), options: .backwards,
//					  range: dotIdx.upperBound..<path.endIndex, locale: nil) != nil {
//			// dir marker is after last '.'
//			return
//			}
//
//		path = String(path[..<dotIdx.lowerBound])
		
		return self
	}
	
	//
	func Components() -> [String] {
		return path.split(separator: dirMarker).ToStringArray()
	}
	
	// Removes all characters after last component marker and the marker itself.
	@discardableResult func RemoveLastComponent() -> PathClass {
		if path.isEmpty { return self }
		if path == String(dirMarker) {
			path = ""
			return self
		}
		
		var range : Range<String.Index> = path.startIndex..<path.endIndex
		
		if LastCharIsMarker() {
			range = path.startIndex..<path.index(before: path.endIndex)
		}
		if let idx = path.range(of: String(dirMarker), options: .backwards, range: range, locale: nil) {
			// FIX : idx.upperBound -> idx.lowerBound
			path.removeSubrange(idx.lowerBound..<path.endIndex)
		}
		else {
			path = ""
		}
		
		return self
	}
	
	// Change the component marker and convert path's markers to such.
	// Existing characters the same as the new marker in the path will
	// not be converted.
	// 'A/B/C:s:3/D'. newMarker = ':' -> 'A:B:C:s:3:D'.
	@discardableResult func ConvertMarkers(marker: Character) -> PathClass {
		if marker == dirMarker { return self }
		
		path.ReplaceAllM(chars: String(dirMarker), with: marker)
		
		dirMarker = marker
		
		return self
	}
	
	// Change the directory marker and convert path's markers to such.
	// Existing characters the same as the new marker will be converted to the
	// old marker.
	// 'A/B/C:s:3/D'. newMarker = ':' -> 'A:B:C/s/3:D'.
	@discardableResult func SwapDirMarkers(marker: Character) -> PathClass {
		if marker == dirMarker { return self }
		
		var s = ""
		for c in path {
			if c == dirMarker { s.append(marker) }
			else if c == marker { s.append(dirMarker) }
			else { s.append(c) }
		}
		
		path = s
		
		dirMarker = marker
		
		return self
	}
	
	// Change the directory marker. The path's directory markers are not changed.
	// 'A/B/C:s:3/D'. newMarker = ':' -> 'A/B/C:s:3/D'.
	@discardableResult func ChangeDir(marker: Character) -> PathClass {
		dirMarker = marker
		
		return self
	}
	
	//----------------------------------------------
	// MARK:- Operators

	static func == (LHS : PathClass, RHS : PathClass) -> Bool {
		return LHS.RemoveDirMarker().path == RHS.RemoveDirMarker().path
	}

	static func != (LHS : PathClass, RHS : PathClass) -> Bool {
		return LHS.RemoveDirMarker().path != RHS.RemoveDirMarker().path
	}
	
	static func < (LHS : PathClass, RHS : PathClass) -> Bool {
		return LHS.RemoveDirMarker().path < RHS.RemoveDirMarker().path
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



