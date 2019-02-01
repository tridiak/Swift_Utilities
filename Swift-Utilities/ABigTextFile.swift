//
//  ABigTextFile.swift
//  Swift-Utilities
//
//  Created by tridiak on 26/01/19.
//  Copyright © 2019 tridiak. All rights reserved.
//

import Foundation

/*
Loads very big text files.
Super class ABigBinary does all the heavy lifting.

The class has a line cache similar to ABigBinaryFiles's cache.
*/
class ABigTextFile : ABigBinaryFile, Sequence { // Sequence later
	
	private(set) var textLF : ATextFile.NewLine = .unix
	var IsWindows : Bool { return textLF == .windows }
	
	private(set) var maxLines : UInt16
	
	private var lineFeedPositions : [UInt64] = []
	
	private var lastIsLF = false
	
	private var lineCache : [UInt64:String] = [:]
	
	private var lineHistory : [UInt64] = []
	
	private var doNotUpdate = false
	
	//-------------------
	// Init with a text file represented by a descriptor.
	init?(desc : Int32, blockSz : UInt16, maxBlks : UInt64, maxLines M : UInt16, newLine : ATextFile.NewLine = .unix) throws {
		maxLines = M
		try super.init(desc: desc, blockSz: blockSz, maxBlks: maxBlks)
		textLF = newLine
		
		RetrieveLinePositions()
	}
	
	// Init with a text file represented by a path.
	init?(path P : String, blockSz : UInt16, maxBlks : UInt64, maxLines M : UInt16, newLine : ATextFile.NewLine = .unix) throws {
		maxLines = M
		try super.init(path: P, blockSz: blockSz, maxBlks: maxBlks)
		textLF = newLine
		
		RetrieveLinePositions()
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
	
	// Retrieve all line feed indexes of the text file.
	private func RetrieveLinePositions() {
		lastIsLF = false
		lineFeedPositions.removeAll()
		
		if dataSize == 0 { return }
		lineFeedPositions.append(0)
		
		var pos : UInt64 = 0
		for _ in 0..<dataSize {
			if (IsLineFeed(idx: &pos)) {
				// For windows, the pos will be incremented by 1.
			//	print("Line Index \(pos)")
				lineFeedPositions.append(pos)
			}
			pos += 1
		}
		
		if textLF == .windows {
			pos = dataSize - 2
		}
		else {
			pos = dataSize - 1
		}
		lastIsLF = IsLineFeed(idx: &pos)
	} // RetrieveLinePositions()
	
	// Purge cache
	func Purge() {
		lineCache.removeAll()
		lineHistory.removeAll()
	}
	
	// Calls Purge() & RetrieveLinePositions()
	func Refresh() {
		Purge()
		RetrieveLinePositions()
	}
	
	// Factors in the fact the last character may be a line feed
	var lineCount : UInt64 { return UInt64(lastIsLF ? lineFeedPositions.count + 1 : lineFeedPositions.count) }
	
	private func AddToHistory(line : UInt64, s : String) {
		if doNotUpdate { return }
		
		if lineHistory.count == maxLines {
			let old = lineHistory.removeFirst()
			lineCache.removeValue(forKey: old)
		}
		
		lineHistory.append(line)
		lineCache[line] = s
	} // AddToHistory()
	
	// Note: super class uses UInt64. This class uses Int.
	// Stops compiler from complaining about ambiguity.
	subscript(line : Int) -> String? {
		if line < 0 || line >= lineCount { return nil }
		
		if let S = lineCache[UInt64(line)] { return S }
		
		var pos : Int64 = IsWindows ? -2 : -1
		if line > 0 {
			pos = Int64(lineFeedPositions[line])
		}
		
		var nextLF : Int64 = 0
		if line >= lineCount - 2 {
			nextLF = Int64(dataSize)
			if lastIsLF { nextLF -= IsWindows ? -2 : -1 }
		}
		else {
			nextLF = Int64(lineFeedPositions[line + 1])
		}
		
		let actualPos = UInt64(IsWindows ? pos + 2 : pos + 1)
		// This could happen if underlying file has changed.
		// Do a purge here or let the user decide.
		guard let chars = self[actualPos..<UInt64(nextLF)] else { return nil }
		let characters = chars.map({ (C) -> Character in
			return Character(UnicodeScalar(C))
		})
		
		let S = String(characters)
		AddToHistory(line: UInt64(line), s: S)
		
		return S
	} // subscript
	
	// Range of lines. If out of bounds, an empty array is returned.
	subscript(range: Range<Int>) -> [String] {
		let length = range.upperBound - range.lowerBound
		//if length >= lineCount { return nil }
		
		if length == 0 { return [] }
		if length == 1 {
			if let S = self[range.lowerBound] { return [S] }
			else { return [] }
		}
		
		var lines : [String] = []
		for idx in range.lowerBound..<range.upperBound {
			guard let s = self[idx] else { break }
			lines.append(s)
		}
		
		return lines
	} // subscript
	
	// Load all lines of the text file into memory.
	// All or nothing. Nothing will probably result in a memory exception.
	var allLines : [String] {
		doNotUpdate = true
		let A = self[0..<Int(lineCount)]
		doNotUpdate = false
		
		return A
	}
	
	//------------------------------
	
	func makeIterator() -> BigATFIterator {
		return BigATFIterator(DC: self, index: 0)
	}
}

//--------------------------------
// MARK:- ATF Iterator

public struct BigATFIterator : IteratorProtocol {
	let DC : ABigTextFile
	var index : Int = 0
	
	public mutating func next() -> String? {
		let name = DC[index]
		
		index += 1
		return name
		
	}
	
	public typealias Element = String
}
