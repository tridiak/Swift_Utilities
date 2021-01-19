//
//  ArrayExt.swift
//  Links
//
//  Created by tridiak on 12/09/19.
//  Copyright © 2019 tridiak. All rights reserved.
//

import Foundation

extension Array {
	func RndElement() -> Element? {
		if self.isEmpty { return nil }
		if self.count == 1 { return self.first! }
		let R = Int(arc4random()) % self.count
		return self[R]
	}
}

// Immutable array struct. Once size is set, it cannot be changed.
struct ImmArray<T> : Collection {
	func index(after i: Int) -> Int {
		return array.index(after: i)
	}
	
	subscript(position: Int) -> T {
		get { return array[position] }
		set(V) { array[position] = V }
	}
	
	
	var startIndex: Int { return array.startIndex }
	
	var endIndex: Int { return array.endIndex }
	
	public typealias Element = T
	public typealias Index = Int
	
	private var array : [T]
	private(set) var elemCount : Int = 0
	
	init?(count: UInt, default D: T) {
		if count >= Int.max { return nil }
		
		elemCount = Int(count)
		array = Array(repeating: D, count: elemCount)
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
	
	func AsArray() -> [T] {
		return array
	}
	
	/// Set array to passed array. If passed array count is less than immutable array count,
	/// the last element of the passed array will be assigned to the remaining elements.
	/// If the passed array count is greater than the immutable array count, only the first N elements
	/// will be copied. An empty array will change nothing.
	mutating func SetTo(array A: [T]) {
		if A.isEmpty { return }
		if A.count <= elemCount {
			array = A
			if A.count < elemCount {
				for _ in A.count..<elemCount { array.append(A.first!) }
			}
		}
		else {
			array = Array(A[0..<elemCount])
		}
	}
} // ImmArray

// Iterator
public struct IMAIterator<T> : IteratorProtocol {
	let IMA : ImmArray<T>
	var index : Int = 0
	
	public mutating func next() -> T? {
		if index >= IMA.elemCount { return nil }
		let E = IMA[index]
		
		index += 1
		
		return E
	}
}
