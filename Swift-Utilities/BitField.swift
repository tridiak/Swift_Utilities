//
//  BitField.swift
//  Swift-Utilities
//
//  Created by tridiak on 16/12/18.
//  Copyright © 2018 tridiak. All rights reserved.
//

import Foundation

struct BitField : CustomStringConvertible {
	// Description prints out starting from lowest bit.
	var description: String {
		var s = ""
		var spaceIdx = 1
		for idx in 0..<bitCount {
			s += self[idx] ? "1" : "0"
			if spaceIdx == descSpace {
				s += " "
				spaceIdx = 0
			}
			spaceIdx += 1
		}
		
		return s
	}
	
	// description space insertion step.
	var descSpace : UInt8 = 255
	
	//---------------------------
	private(set) var bitField : [UInt64]
	private(set) var bitCount : UInt8
	
	// nil only returned if bitCount is 0.
	init?(bitCount BC: UInt8) {
		if BC == 0 { return nil }
		let aryCt = (BC - 1) / 64 + 1
		bitField = Array.init(repeating: 0, count: Int(aryCt) )
		bitCount = BC
		
		lastAryIndex = Int((bitCount - 1) / 64)
		let lowestUnusedBit = UInt64((bitCount - 1) % 64) + 1
		keepMask = (bitCount % 64) == 0 ? UInt64.max : (1 << lowestUnusedBit) - 1
	}
	
	// Init with an unisgned integer.
	// Integer's type will define the bit width.
	init<T : UnsignedInteger>(value : T) {
		bitCount = UInt8(value.bitWidth)
		bitField = Array.init(repeating: 0, count: 1)
		
		bitField[0] = UInt64(value)
		
		lastAryIndex = Int((bitCount - 1) / 64)
		let lowestUnusedBit = UInt64((bitCount - 1) % 64) + 1
		keepMask = (bitCount % 64) == 0 ? UInt64.max : (1 << lowestUnusedBit) - 1
		
		ClearUnused()
	}
	
	// Copy constructor essentially
	init(BF : BitField) {
		bitField = BF.bitField
		bitCount = BF.bitCount
		
		lastAryIndex = Int((bitCount - 1) / 64)
		let lowestUnusedBit = UInt64((bitCount - 1) % 64) + 1
		keepMask = (bitCount % 64) == 0 ? UInt64.max : (1 << lowestUnusedBit) - 1
	}
	
	// Unused high end bits of the last array element are unused and must
	// always be zero.
	
	private let lastAryIndex : Int
	private let keepMask : UInt64
	
	mutating private func ClearUnused() {
		if (bitCount % 64) == 0 { return }
		
		bitField[lastAryIndex] &= keepMask
	}
	
	// MARK:-
	
	// Returns first 64 bits of the bit field
	var first : UInt64 { return bitField[0] }
	
	// Which bit. If the bit number is >= bitCount, false will be returned.
	// In the case of setting, nothing will happen.
	subscript(bit : UInt8) -> Bool {
		get {
			if bit >= bitCount { return false }
			let aryIdx = (bit) / 64
			let mod = bit % 64
			
			return bitField[Int(aryIdx)] & (1 << mod) > 0
		}
		set(V) {
			if bit >= bitCount { return }
			let aryIdx = (bit) / 64
			let mod = bit % 64
			
			if V {
				bitField[Int(aryIdx)] |= (1 << mod)
			}
			else {
				var b = bitField[Int(aryIdx)]
				b = b & (UInt64.max - (1 << mod))
				bitField[Int(aryIdx)] = b
			}
		}
	} // subscript
	
	// And a value to the first N bits (max of 64)
	mutating func And<T : UnsignedInteger> (V : T) {
		let mask = V.bitWidth < 64 ? UInt64((1 << V.bitWidth) - 1) : UInt64.max
		let bfKeep = UInt64.max - mask
		let value = UInt64(V) & mask
		bitField[0] &= value + bfKeep
		
		ClearUnused()
	}
	
	// Or a value to the first N bits (max of 64)
	mutating func Or<T : UnsignedInteger> (V : T) {
		let mask = V.bitWidth < 64 ? UInt64((1 << V.bitWidth) - 1) : UInt64.max
		bitField[0] |= UInt64(V) & mask
		
		ClearUnused()
	}
	
	// Xor a value to the first N bits (max of 64)
	mutating func Xor<T : UnsignedInteger> (V : T) {
		let mask = V.bitWidth < 64 ? UInt64((1 << V.bitWidth) - 1) : UInt64.max
		bitField[0] ^= UInt64(V) & mask
		
		ClearUnused()
	}
	
	// And another bitfield to this one.
	// The number of bits affected is the lesser count of both.
	mutating func And(RHS : BitField) {
		var lesser = bitCount < RHS.bitCount ? bitCount : RHS.bitCount
		
		var aryIdx = 0
		while lesser > 64 {
			bitField[aryIdx] &= RHS.bitField[aryIdx]
			aryIdx += 1
			lesser -= 64
		}
		
		let mask = lesser == 64 ? UInt64.max : (1 << lesser) - 1
		let keep = UInt64.max - mask
		bitField[aryIdx] = (bitField[aryIdx] & keep) | ((bitField[aryIdx] & RHS.bitField[aryIdx]) & mask)
		
		ClearUnused()
	}
	
	// Or another bitfield to this one.
	// The number of bits affected is the lesser count of both.
	mutating func Or(RHS : BitField) {
		var lesser = bitCount < RHS.bitCount ? bitCount : RHS.bitCount
		
		var aryIdx = 0
		while lesser > 64 {
			bitField[aryIdx] |= RHS.bitField[aryIdx]
			aryIdx += 1
			lesser -= 64
		}
		
		let mask = lesser == 64 ? UInt64.max : (1 << lesser) - 1
		bitField[aryIdx] |= RHS.bitField[aryIdx] & mask
		
		ClearUnused()
	}
	
	// Xor another bitfield to this one.
	// The number of bits affected is the lesser count of both.
	mutating func Xor(RHS : BitField) {
		var lesser = bitCount < RHS.bitCount ? bitCount : RHS.bitCount
		
		var aryIdx = 0
		while lesser > 64 {
			bitField[aryIdx] ^= RHS.bitField[aryIdx]
			aryIdx += 1
			lesser -= 64
		}
		
		let mask = lesser == 64 ? UInt64.max : (1 << lesser) - 1
		bitField[aryIdx] ^= RHS.bitField[aryIdx] & mask
		
		ClearUnused()
	}
	
	// shift right one bit for the passed array.
	mutating private func ShiftRightOne(val : inout [UInt64]) {
		var topInsert = false
		var aryIdx = Int((bitCount - 1) / 64)
		while (aryIdx >= 0) {
			let b = (val[aryIdx] & 1) == 1
			val[aryIdx] = val[aryIdx] >> 1
			if topInsert { val[aryIdx] |= (1 << 63) }
			
			topInsert = b
			aryIdx -= 1
		}
	}
	
	// "division"
	mutating func ShiftRight(bits: UInt8) {
		// If number of bits shifted >= bitCount, the result will always be zero.
		if bits >= bitCount {
			for idx in 0..<bitField.count {
				bitField[idx] = 0
			}
			return
		}
		
		// If bit shift count is a multiple of 64, just set lower array elements
		// to higher array elements.
		if (bits % 64) == 0 {
			let step = Int(bits / 64)
			var aryIdx = 0
			let aryCount = Int((bitCount - 1) / 64)
			while aryIdx <= aryCount - step {
				bitField[aryIdx] = bitField[aryIdx + step]
				aryIdx += 1
			}
			
			// Zero the top end elements.
			while aryIdx <= aryCount {
				bitField[aryIdx] = 0
				aryIdx += 1
			}
			
			return
		}
		
		var BF = bitField
		for _ in 0..<bits {
			ShiftRightOne(val: &BF)
		}
		bitField = BF
	}
	
	// Shift left all bits in array one
	mutating private func ShiftLeftOne(val : inout [UInt64]) {
		var btmInsert = false
		let aryMax = Int((bitCount - 1) / 64)
		var aryIdx = 0
		while aryIdx <= aryMax {
			let b = (val[aryIdx] & (1 << 63)) > 0
			val[aryIdx] = val[aryIdx] << 1
			if btmInsert { val[aryIdx] |= 1 }
			
			btmInsert = b
			aryIdx += 1
		}
	}
	
	// "Multiplication"
	mutating func ShiftLeft(bits: UInt8) {
		// If number of bits shifted >= bitCount, the result will always be zero.
		if bits >= bitCount {
			for idx in 0..<bitField.count {
				bitField[idx] = 0
			}
			return
		}
		
		// If bit shift count is a multiple of 64, just set higher array elements
		// to lower array elements.
		// Highest array element must have unused bits set to zero.
		if (bits % 64) == 0 {
			let step = Int(bits / 64)
			
			let aryCount = Int((bitCount - 1) / 64)
			var aryIdx = aryCount
			while aryIdx >= step {
				bitField[aryIdx] = bitField[aryIdx - step]
				aryIdx -= 1
			}
			
			// Zero the top end elements.
			while aryIdx >= 0 {
				bitField[aryIdx] = 0
				aryIdx -= 1
			}
			
			return
		}
		
		var BF = bitField
		for _ in 0..<bits {
			ShiftLeftOne(val: &BF)
		}
		bitField = BF
		
		ClearUnused()
	}
	
	// Invert all the bits
	mutating func Not() {
		if bitCount == 0 { return }
		
		for idx in 0...Int(((bitCount - 1) / 64) ) {
			bitField[idx] ^= UInt64.max
		}
	}
	
	// Zero all the bits
	mutating func Zero() {
		if bitCount == 0 { return }
		
		for idx in 0...Int(((bitCount - 1) / 64) ) {
			bitField[idx] = 0
		}
	}
	
	// Set all bits
	mutating func Set() {
		if bitCount == 0 { return }
		
		for idx in 0...Int(((bitCount - 1) / 64) ) {
			bitField[idx] = UInt64.max
		}
	}
	
	//-----------------------------------------------------
	// MARK:- Logical Operators
	
	// MARK: BF <op> BF
	// And two bitfield structs
	static func &(LHS : BitField, RHS : BitField) -> BitField {
		var bf = LHS
		bf.And(RHS: RHS)
		
		return bf
	}
	
	// Or two bitfield structs
	static func |(LHS : BitField, RHS : BitField) -> BitField {
		var bf = LHS
		bf.Or(RHS: RHS)
		
		return bf
	}
	
	// Xor two bitfield structs
	static func ^(LHS : BitField, RHS : BitField) -> BitField {
		var bf = LHS
		bf.Xor(RHS: RHS)
		
		return bf
	}
	
	// Not/! one bitfield struct
	static prefix func !(LHS : BitField) -> BitField {
		var bf = LHS
		bf.Not()
		
		return bf
	}
	
	// MARK: BF <op> UInt
	// Note. Because maximum integer size is 64bit, only the first 64bits of the bit field
	// are ever used.
	
	// Bit-And an integer with a BitField - LHS
	static func &<T : UnsignedInteger> (LHS : BitField, RHS : T) -> BitField {
		var bf = LHS
		bf.And(V:RHS)
		
		return bf
	}
	
	// Bit-Or an integer with a BitField - LHS
	static func |<T :UnsignedInteger> (LHS : BitField, RHS : T) -> BitField {
		var bf = LHS
		bf.Or(V:RHS)
		
		return bf
	}
	
	// Bit-Xor an integer with a BitField - LHS
	static func ^<T : UnsignedInteger> (LHS : BitField, RHS : T) -> BitField {
		var bf = LHS
		bf.Xor(V:RHS)
		
		return bf
	}
	
	static func << (LHS : BitField, RHS : UInt8) {
		fatalError("Not finished")
	}
	
	// MARK: UInt <op> BF
	// Bit-And an integer with a BitField - RHS
	static func &<T : UnsignedInteger> (LHS : T, RHS : BitField) -> T {
		let W = LHS.bitWidth
		let B = RHS.first
		switch W {
			case 8: return T(UInt8(LHS) & UInt8( B & 0xFF))
			case 16: return T(UInt16(LHS) & UInt16( B & 0xFFFF))
			case 32: return T(UInt32(LHS) & UInt32( B & 0xFFFF_FFFF))
			case 64: return T(UInt64(LHS) & UInt64( B & 0xFFFF_FFFF_FFFF_FFFF))
			default: return 0
		}
	}
	
	// Bit-Or an integer with a BitField - RHS
	static func |<T : UnsignedInteger> (LHS : T, RHS : BitField) -> T {
		let W = LHS.bitWidth
		let B = RHS.first
		switch W {
			case 8: return T(UInt8(LHS) | UInt8( B & 0xFF))
			case 16: return T(UInt16(LHS) | UInt16( B & 0xFFFF))
			case 32: return T(UInt32(LHS) | UInt32( B & 0xFFFF_FFFF))
			case 64: return T(UInt64(LHS) | UInt64( B & 0xFFFF_FFFF_FFFF_FFFF))
			default: return 0
		}
	}
	
	// Bit-Xor an integer with a BitField - RHS
	static func ^<T : UnsignedInteger> (LHS : T, RHS : BitField) -> T {
		let W = LHS.bitWidth
		let B = RHS.first
		switch W {
			case 8: return T(UInt8(LHS) ^ UInt8( B & 0xFF))
			case 16: return T(UInt16(LHS) ^ UInt16( B & 0xFFFF))
			case 32: return T(UInt32(LHS) ^ UInt32( B & 0xFFFF_FFFF))
			case 64: return T(UInt64(LHS) ^ UInt64( B & 0xFFFF_FFFF_FFFF_FFFF))
			default: return 0
		}
	}
	
	// Left Shift all bits
	static func << (LHS : BitField, RHS : UInt8) -> BitField {
		var BF = LHS
		BF.ShiftLeft(bits: RHS)
		
		return BF
	}
	
	// Right Shift
	static func >> (LHS : BitField, RHS : UInt8) -> BitField {
		var BF = LHS
		BF.ShiftRight(bits: RHS)
		
		return BF
	}
	
	//------------------
	// MARK: Comparison Operators
	// MARK: BF <op> UInt
	// The following compare the passed value where the bit field
	// value has the same number of bits as the passed type.
	// i.e. BitField 11001100_11111111 == UInt8(255) will compare to BF 11111111 which will be true.
	//	BitField 11001100_11111111 == UInt16(255) will compare to BF 11001100_11111111 which will be false.
	// So when using the operators, use must ensure you the value you pass is the correct type you wish to use.
	
	// Equal to.
	static func ==<T : UnsignedInteger> (LHS : BitField, RHS : T) -> Bool {
		let W = RHS.bitWidth
		let mask = W < 64 ? UInt64((1 << W) - 1) : UInt64.max
		return LHS.first & mask == UInt64(RHS)
	}
	
	// Not equal to
	static func !=<T : UnsignedInteger> (LHS : BitField, RHS : T) -> Bool {
		let mask = RHS.bitWidth < 64 ? UInt64((1 << RHS.bitWidth) - 1) : UInt64.max
		return LHS.first & mask != UInt64(RHS)
	}
	
	// Less than
	static func <<T : UnsignedInteger> (LHS : BitField, RHS : T) -> Bool {
		let mask = RHS.bitWidth < 64 ? UInt64((1 << RHS.bitWidth) - 1) : UInt64.max
		return LHS.first & mask < UInt64(RHS)
	}
	
	// Greater than
	static func ><T : UnsignedInteger> (LHS : BitField, RHS : T) -> Bool {
		let mask = RHS.bitWidth < 64 ? UInt64((1 << RHS.bitWidth) - 1) : UInt64.max
		return LHS.first & mask > UInt64(RHS)
	}
	
	//------------------
	// MARK: BF <op> BF
	// Check if two bitfields are equal. If the bit count differs, false
	// is always returned.
	static func == (LHS : BitField, RHS : BitField) -> Bool {
		if LHS.bitCount != RHS.bitCount { return false }
		
		let max = Int((LHS.bitCount - 1) / 64 + 1 )
		for idx in 0..<max {
			if LHS.bitField[idx] != RHS.bitField[idx] { return false }
		}
		
		return true
	}
	
	// Check if two bitfields are not equal. If the bit count differs, false
	// is always returned.
	static func != (LHS : BitField, RHS : BitField) -> Bool {
		if LHS.bitCount != RHS.bitCount { return false }
		
		let max = Int((LHS.bitCount - 1) / 64 + 1 )
		for idx in 0..<max {
			if LHS.bitField[idx] == RHS.bitField[idx] { return false }
		}
		
		return true
	}
}

func test() {
	var bf = BitField(bitCount: 8)!
	var bf2 = BitField(bitCount: 16)!
	
	bf[1] = true;bf[3] = true;bf[5] = true;bf[7] = true
	bf2[0] = true;bf2[2] = true;bf2[4] = true;bf2[6] = true
	bf2[8] = true;bf2[10] = true;bf2[12] = true;bf2[14] = true
	
	print("And: \(bf & bf2)")
	print("Or: \(bf | bf2)")
	print("Xor: \(bf ^ bf2)")
}
