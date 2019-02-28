//
//  AStringFile.swift
//  Swift-Utilities
//
//  Created by tridiak on 18/01/19.
//  Copyright © 2019 tridiak. All rights reserved.
//

import Foundation

enum ATFExceptions : Error {
	case invalidUTF8Char
}

// Load a text file into memory.
// Can select one of the standard line feeds.
// Default is unix.
// This is a subclass of ABinaryFile which does all the heavy lifting.
class ATextFile : ABinaryFile, Sequence {
	enum NewLine {
		case classicMac
		case unix
		case windows
		// CR 13, LF 10, CRLF 13 10
	}
	
	private(set) var textLF : NewLine = .unix
	// cache
	private var lines : [String] = []
	
	//-------------------
	override init?(descriptor: Int32) {
		super.init(descriptor: descriptor)
		
		do { try RetrieveLines() }
		catch (let E) { print(E); return nil }
	}
	
	override init?(path : String) {
		super.init(path: path)
		
		do { try RetrieveLines() }
		catch (let E) { print(E); return nil }
	}
	
	//--------------------
	// 'idx' is inout because windows new line is two characters and we
	// will need to increment the index.
	private func IsLineFeed(idx : inout UInt64) -> Bool {
		let C = super[idx]!
		
		switch textLF {
			case .classicMac:
				return C == 13
			case .unix:
				return C == 10
			case .windows:
				if C != 13 { return false }
				if idx + 1 == dataSize { return false }
				if C == 10 {
					idx += 1
					return true
				}
				return false
		}
	} // IsLineFeed()
	
	// Will throw exception if UTF8 character sequence is invalid
	private func RetrieveLines() throws {
		lines.removeAll()
		var s : [UInt8] = []
		var idx : UInt64 = 0
		var lastIsLF = true
		for _ in 0..<dataSize {
			let c = super[idx]!
			if IsLineFeed(idx: &idx) {
				guard let S = String(bytes: s, encoding: .utf8) else {
					throw ATFExceptions.invalidUTF8Char
				}
				lines.append(S)
				s.removeAll()
				lastIsLF = true
			}
			else {
				s.append(c)
				lastIsLF = false
			}
			
			idx += 1
		}
		
		if !lastIsLF {
			guard let S = String(bytes: s, encoding: .utf8) else {
				throw ATFExceptions.invalidUTF8Char
			}
			lines.append(S)
		}
	} // RetrieveLines()
	
	var lineCount : UInt64 { return UInt64(lines.count) }
	
	// Note: super class uses UInt64. This class uses Int.
	// Stops compiler from complaining about ambiguity.
	subscript(idx : Int) -> String? {
		if idx >= lineCount { return nil }
		return lines[Int(idx)]
	}
	
	//------------------------------
	
	func makeIterator() -> ATFIterator {
		return ATFIterator(DC: self, index: 0)
	}
}

//--------------------------------
// MARK:- ATF Iterator

public struct ATFIterator : IteratorProtocol {
	let DC : ATextFile
	var index : Int = 0
	
	public mutating func next() -> String? {
		let name = DC[index]
		
		index += 1
		return name
		
	}
	
	public typealias Element = String
}
