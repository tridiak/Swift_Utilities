//
//  Misc.swift
//  Swift-Utilities
//
//  Created by tridiak on 9/12/18.
//  Copyright © 2018 tridiak. All rights reserved.
//

import Foundation

// Immutable array struct. Once size is set, it cannot be changed.
struct ImmArray<T> : Sequence {
	private var array : [T]
	private(set) var elemCount : Int
	
	init?(count: UInt, default D: T) {
		if count >= Int.max { return nil }
		
		elemCount = Int(count)
		array = Array(repeating: D, count: elemCount)
	}
	
	subscript(index : Int) -> T? {
		get {
			if index < 0 || index >= elemCount { return nil }
			return array[index]
		}
		set(V) {
			if index < 0 || index >= elemCount { return }
			array[index] = V!
		}
	}
	
	// Return comparison of element 1 & element 2.
	typealias SortBlock = (T,T) -> ComparisonResult
	
	// Sort array
	mutating func Sort(block: SortBlock) {
		array.sort { (E1, E2) -> Bool in
			return block(E1,E2) == ComparisonResult.orderedAscending
		}
	}
	
	//
	func makeIterator() -> IMAIterator<T> {
		return IMAIterator<T>(IMA: self, index: 0)
	}
	
	// Return true to stop iteration
	typealias IterBlock = (T) -> Bool
	
	// Iterate over elements passing a block.
	func Iterate(block: IterBlock) {
		for E in array {
			if block(E) { break }
		}
	}
}

// Iterator
public struct IMAIterator<T> : IteratorProtocol {
	let IMA : ImmArray<T>
	var index : Int = 0
	
	public mutating func next() -> T? {
		let E = IMA[index]
		index += 1
		
		return E
	}
}
