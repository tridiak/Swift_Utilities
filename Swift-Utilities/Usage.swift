//
//  Usage.swift
//  Swift-Utilities
//
//  Created by tridiak on 9/12/18.
//  Copyright © 2018 tridiak. All rights reserved.
//

import Foundation

func PNUsage() {
	let N = GetNegative()
	let P = GetPositive()
	let Z = GetZero()
	
	print(N)
	print(P)
	print(Z)
	
	print(-1000 * P)
	print(-1000 * N)
	print(-1000 * Z)
	
}

func DirContentsUsage() {
	let path = "/Users/tridiak/Documents/temp/Spells/"
	if let dc = DirContents(path: path) {
		
		do {
			try dc.Gather()
		}
		catch DirContents.DirContentsEx.notADir {
			print("\(path) is not a dir")
		}
		catch {
			print(error)
		}

		dc.Sort()
		dc.nameOrPathFlag = true

		for item in dc {
			print(item)
		}
	}
	// /Users/tridiak/Documents/temp/Spells
}

func StringStuffUsage() {
	let s = "1234567890.qwertyuio"
	
	print("*** Remove from \(s) all digits, non-digits")
	print(s.RemoveFrom(set: "0123456789", invert: false))
	print(s.RemoveFrom(set: "0123456789", invert: true))
	
	print("*** Replace all digits in \(s) with X")
	print(s.ReplaceAll(chars: "0123456789", with: "X"))
	
	print("*** Before/After last character '.'")
	print(s.StringAfterLast(char: ".") ?? "nil")
	print(s.StringBeforeLast(char: ".") ?? "nil")
	
	let r = "111dd5555...hhh"
	print("Reduce consecutive characters")
	print("\(r) -> \(r.ReduceConsecutiveChars() )")
	print("\(r) -> \(r.ReduceConsecutiveCharsOf(char: "5") )")
	
	print("*** Convert integer with suffix to")
	print("1.25kb -> \("1.25kb".ConvertSuffixedToUInt()  ?? 0)")
	print("1.25kib -> \("1.25kib".ConvertSuffixedToUInt() ?? 0)")
	print("1.25ee -> \("1.25ee".ConvertSuffixedToUInt() ?? 0)" )
	print("1.2.5kb -> \("1.2.5kb".ConvertSuffixedToUInt() ?? 0)")
	
	print("*** Equal Split")
	print("1122334455".EqualSplit(charCount: 2) ?? "nil")
	print("1122334455".EqualSplit(charCount: 5) ?? "nil")
	print("1122334455".EqualSplit(charCount: 4) ?? "nil")
	
	print("*** Hex to UInt")
	print("FF".HexToUInt() ?? "nil")
	print("GG".HexToUInt() ?? "nil")
	print("FF1234".HexToUInt() ?? "nil")
	
	print("*** UInt to byte string")
	print(UInt(12345).ByteString1000())
	print(UInt(12345).ByteString1024())
	
}

func PathClassUsage() {
	let path = "/A/Path/to/text/file##"
	let pc = PathClass(path: path)!
	
	pc.RemoveLastComponent()
	print(pc.path)
	
	pc.AppendDirMarker()
	print(pc.path)
	
	pc.RemoveDirMarker()
	print(pc.path)
	
	pc.Add(path: "/awesome.txt")
	print(pc.path)
	
	pc.Add(path: "blob")
	print(pc.path)
	
	pc.Prepend(path: "/really")
	print(pc.path)
	
	pc.Add(suffix: "gob")
	print(pc.path)
	
	pc.AppendDirMarker()
	pc.Add(suffix: "boo")
	print(pc.path)
	
	try? pc.RemoveSuffix()
	print(pc.path)
	
	try? pc.RemoveSuffix()
	print(pc.path)
	
	pc.RemoveDirMarker()
	try? pc.RemoveSuffix()
	print(pc.path)
	
	print(pc.Components())
	
	pc.SwapDirMarkers(marker: "#")
	print(pc.path)
	
	pc.SwapDirMarkers(marker: "/")
	pc.ConvertMarkers(marker: "#")
	print(pc.path)
	
	// Postfix decrement
	pc.SwapDirMarkers(marker: "/")
	pc--
	print(pc.path)
	
	// subscript
	print(pc[0] ?? "nil", pc[1] ?? "nil", pc[100] ?? "nil")
}

func ColourUsage() {
	let col = Colour(red: Col8(255), green: 127, blue: 0)
	let col2 = Colour(red: 1, green: 0.5, blue: 0)
	
	print("RGB")
	print(col)
	print(col2)
	print("Hex String: \(col.HexString(prefix: "&", inclAlpha: false) )")
	print("Hex String Array: \(col.HexString(inclAlpha: false))" )
	
	let cm = col.CMYK
	print("RGB to CMYK \(cm)")
	
	let rg = Colour.CMYKtoRGB(cmyk: cm)
	print("CMYK to RGB \(rg!)")
	
	let hs = Colour.RGBtoHSV(rgb: rg!)
	print("RGB to HSV \(hs!)")
	
	let hsTorg = Colour.HSVtoRGB(hsv: hs!)
	print("HSV to RGB \(hsTorg!)")
	
}

func NumS<T : UnsignedInteger>(_ V: T) -> String {
	return String(V, radix:2)
}

func BitFieldUsage() {
	var bf8 = BitField(value: UInt8(0b01010101))
	var bf16 = BitField(value: UInt16(0b01010101_10101010))
	var bf32 = BitField(value: UInt32(0b01010101_10101010_00000000_11111111))
	var bf99 = BitField(bitCount: 99)!
	for idx in stride(from: 0, to: 99, by: 3) {
		bf99[UInt8(idx)] = true
	}
	
	var bf164 = BitField(bitCount: 164)!
	for idx in stride(from: 0, to: 164, by: 6) {
		bf164[UInt8(idx)] = true
	}
	
	bf8.descSpace = 8
	bf16.descSpace = 8
	bf32.descSpace = 8
	bf99.descSpace = 8
	bf164.descSpace = 8
	
	print("BF8 \(bf8)")
	print("BF16 \(bf16)")
	print("BF32 \(bf32)")
	print("BF99 \(bf99)")
	print("BF164 \(bf164)")
	
	// And(UInt). BF & UInt. UInt & BF.
	print("And ----------------")
	print("BF16 & 255 = \(bf16 & UInt8(255))")
	print("255 & BF16 = \(NumS(UInt8(255) & bf16))")
	print("BF16 & 0 = \(bf16 & UInt8(0))")
	print("0 & BF16 = \(NumS(UInt8(0) & bf16))")
	
	print("BF16 & \(NumS(UInt32.max)) = \(bf16 & UInt32.max)")
	print("\(NumS(UInt32.max)) & BF16 = \(NumS(UInt32.max & bf16))")
	
	print("BF99 & 32 bit:\(NumS(UInt32.max >> 16 )) = \(bf99 & (UInt32.max >> 16))")
	
	// Or(UInt)
	print("Or ----------------")
	print("BF16 | 255 = \(bf16 | UInt8(255))")
	print("255 | BF16 = \(NumS(UInt8(255) | bf16))")
	print("BF16 | 0 = \(bf16 | UInt8(0))")
	print("0 | BF16 = \(NumS(UInt8(0) | bf16))")
	
	print("BF16 | \(NumS(UInt32.max)) = \(bf16 | UInt32.max)")
	print("\(NumS(UInt32.max)) | BF16 = \(NumS(UInt32.max | bf16))")
	
	print("BF99 | 32 bit:\(NumS(UInt32.max >> 16 )) = \(bf99 | (UInt32.max >> 16))")
	
	// Xor(UInt)
	print("Xor ----------------")
	print("BF16 ^ 255 = \(bf16 ^ UInt8(255))")
	print("255 ^ BF16 = \(NumS(UInt8(255) ^ bf16))")
	print("BF16 ^ 0 = \(bf16 ^ UInt8(0))")
	print("0 ^ BF16 = \(NumS(UInt8(0) ^ bf16))")
	
	print("BF16 ^ \(NumS(UInt32.max)) = \(bf16 ^ UInt32.max)")
	print("\(NumS(UInt32.max)) ^ BF16 = \(NumS(UInt32.max ^ bf16))")
	
	print("BF99 ^ 32 bit:\(NumS(UInt32.max >> 16 )) = \(bf99 ^ (UInt32.max >> 16))")
	
	// And(BF)
	print("BF.And() --------------")
	var dummy = bf16
	dummy.And(RHS: bf8)
	print("bf16 & bf8 = \(dummy)")
	dummy = bf16
	dummy.And(RHS:bf99)
	print("bf16 & bf99 = \(dummy)")
	
	// Or(BF)
	print("BF.Or() --------------")
	dummy = bf16
	dummy.Or(RHS: bf8)
	print("bf16 | bf8 = \(dummy)")
	dummy = bf16
	dummy.Or(RHS:bf99)
	print("bf16 | bf99 = \(dummy)")
	
	// Xor(BF)
	print("BF.Xor() --------------")
	dummy = bf16
	dummy.Xor(RHS: bf8)
	print("bf16 ^ bf8 = \(dummy)")
	dummy = bf16
	dummy.Xor(RHS:bf99)
	print("bf16 ^ bf99 = \(dummy)")
	
	// Not(BF), !BF
	print("BF Not(), ! --------------")
	dummy = bf16
	dummy = !dummy
	print("!bf16 = \(dummy)")
	dummy.Not()
	print("invert bf16 = \(dummy)")
	
	// Zero
	print("BF --------------")
	dummy = bf16
	dummy.Set()
	print("bf16 Set = \(dummy)")
	dummy = bf16
	dummy.Zero()
	print("bf16 Zero = \(dummy)")
	
	// BF & BF
	print("BF & BF --------------")
	dummy = bf16 & bf99
	print("bf16 & bf99 = \(dummy)")
	dummy = bf99 & bf16
	print("bf99 & bf16 = \(dummy)")
	
	// BF | BF
	print("BF | BF --------------")
	dummy = bf16 | bf99
	print("bf16 | bf99 = \(dummy)")
	dummy = bf99 | bf16
	print("bf99 | bf16 = \(dummy)")
	
	// BF ^ BF
	print("BF ^ BF --------------")
	dummy = bf16 ^ bf99
	print("bf16 ^ bf99 = \(dummy)")
	dummy = bf99 ^ bf16
	print("bf99 ^ bf16 = \(dummy)")
	
	// BF == UInt
	print("BF == UInt ------------")
	print("bf16 = \(bf16.first) aka \(NumS(bf16.first))")
	print("bf16 == 21930 \(bf16 == UInt16(21930))")
	let V24 = UInt32(0b00001111_01010101_10101010)
	print("bf16 == \(V24) aka \(NumS(V24)) = \(bf16 == V24)")
	let V8 = UInt8(0b10101010)
	print("bf16 == \(V8) aka \(NumS(V8)) = \(bf16 == V8)")
	
	// Right Shift
	dummy = bf8
	print("Right Shift 4 \(dummy)", terminator:" -> ")
	dummy.ShiftRight(bits: 4)
	print(dummy)
	
	dummy = bf99
	print("Right Shift 4 \(dummy)", terminator:" -> ")
	dummy.ShiftRight(bits: 4)
	print(dummy)
	
	dummy = bf99
	print("Right Shift 64 \(dummy)", terminator:" -> ")
	dummy.ShiftRight(bits: 64)
	print(dummy)
	
	dummy = bf99 >> 12
	print("Right Shift 12 \(bf99) -> \(dummy)")
	
	// Left Shift
	dummy = bf8
	print("Left Shift 4 \(dummy)", terminator:" -> ")
	dummy.ShiftLeft(bits: 4)
	print(dummy)
	
	dummy = bf99
	print("Left Shift 4 \(dummy)", terminator:" -> ")
	dummy.ShiftLeft(bits: 4)
	print(dummy)
	
	dummy = bf99
	print("Left Shift 64 \(dummy)", terminator:" -> ")
	dummy.ShiftLeft(bits: 64)
	print(dummy)
	
	dummy = bf99 << 12
	print("Left Shift 12 \(bf99) -> \(dummy)")
	
	exit(0)
}

//-----------------------------

func BinaryFileUsage() {
	let filePath = "/Users/tridiak/Programming/Active_Projects/DandD/FeatNameList.txt"
	
	do {
		// Binary file
		let abf = ABinaryFile(path: filePath)!
		for i in 0..<10 {
			print(String(UnicodeScalar(UInt8( abf[UInt64(i)]! )) ), terminator: "")
		}

		print("")
		//
		let bbf = try ABigBinaryFile(path: filePath, blockSz: 256, maxBlks: 16)!
		for _ in 0..<40 {

			let r = UInt64(arc4random()) % bbf.dataSize
			print(r, terminator: ":")
			print(String(UnicodeScalar(UInt8( bbf[r]! )) ), terminator: "\n")
		}
		
		print("")
		
		print("File size \(bbf.dataSize), block size 256, max blocks 16")
		// sequential read time
		BigBinaryAccess(bbf: bbf)
		
		//---------------------------------------
		let bbf2 = try ABigBinaryFile(path: filePath, blockSz: 256, maxBlks: 128)!
		print("File size \(bbf2.dataSize), block size 256, max blocks 128")
		BigBinaryAccess(bbf: bbf2)
		
		//---------------------------------------
		let bbf3 = try ABigBinaryFile(path: filePath, blockSz: 10240, maxBlks: 16)!
		print("File size \(bbf3.dataSize), block size 10240, max blocks 16")
		BigBinaryAccess(bbf: bbf3)
		
		//---------------------------------------
		let bbf4 = try ABigBinaryFile(path: filePath, blockSz: 10240, maxBlks: 128)!
		print("File size \(bbf4.dataSize), block size 10240, max blocks 128")
		BigBinaryAccess(bbf: bbf4)
		
		// subscript range test
		SubscriptRangeTest()
		
	}
	catch (let E) {
		print(E)
	}
}

func SubscriptRangeTest() {
	let filePath = "/Users/tridiak/Programming/Active_Projects/DandD/FeatNameList.txt"
	
	do {
		let bbf = try ABigBinaryFile(path: filePath, blockSz: 256, maxBlks: 16)!
		
		let B1 = bbf[0..<10]!
		let S1 = String(bytes: B1, encoding: .utf8)!
		print(S1)
		print("------------")
		
		let B2 = bbf[32..<290]!
		let S2 = String(bytes: B2, encoding: .utf8)!
		print(S2)
		print("------------")
		
		let B3 = bbf[0..<bbf.dataSize]!
		let S3 = String(bytes: B3, encoding: .utf8)!
		print(S3)
		print("------------")
	}
	catch (let E) {
		print(E)
	}
}

fileprivate func BigBinaryAccess(bbf : ABigBinaryFile) {
	var array : [UInt8] = []
	
	print("Start sequential - all \(bbf.dataSize) bytes")
	var t = CFAbsoluteTimeGetCurrent()

	for i in 0..<bbf.dataSize {
		array.append( bbf[UInt64(i)]! )
	}

	print("Time taken = \(CFAbsoluteTimeGetCurrent() - t)")

	//
	array.removeAll()

	print("Start random - \(bbf.dataSize) byte reads")
	t = CFAbsoluteTimeGetCurrent()
	for _ in 0..<bbf.dataSize {
		let r = UInt64(arc4random()) % bbf.dataSize
		array.append( bbf[r]! )
	}

	print("Time taken = \(CFAbsoluteTimeGetCurrent() - t)")
}

//----------

func ATFUsage() {
	let filePath = "/Users/tridiak/Programming/Active_Projects/DandD/FeatNameList.txt"
	
	do {
		let atf = ATextFile(path: filePath)!
		for idx in 0..<10 {
			print(atf[idx] ?? "<error>")
		}
		
	}
	catch (let E) {
		print(E)
	}
}

func BigATFUsage() {
	let filePath = "/Users/tridiak/Programming/Active_Projects/DandD/FeatNameList.txt"
	
	do {
		if let atf = try ABigTextFile(path: filePath, blockSz: 1024, maxBlks: 64, maxLines: 256) {
			for idx in 0..<10 {
				print(atf[idx] ?? "<error>")
			}
			
			print(atf.allLines)
		}
	}
	catch (let E) {
		print(E)
	}
}

//-------------------------------------------------------------
// MARK: HierNode Usage

class FSNode : HierNode {
	override init(path: String) {
		super.init(path: path)
	}
	
	override func CreateNode(path: PathClass) -> HierNode {
		return FSNode(path: path.path)
	}
	
	override func Children() -> [PathClass] {
		guard let DC = DirContents(path: path.path) else { return [] }
		guard (try? DC.Gather()) != nil else { return [] }
		
		var paths : [PathClass] = []
		DC.nameOrPathFlag = true
		for p in DC {
			if let P = PathClass(path: p) {
				paths.append(P)
			}
		}
		
		return paths
	}
	
	override func CountThis() -> Bool { return true }
	
	override func IterationAction(depth: Int) -> HierNode.IterateResult {
		let S = String(repeating: "\t", count: depth)
		print("\(S)\(path.Components().last ?? "")")
		
		return .rContinue
	}
}

//----
func HierUsage() {
	// Enter own path here.
	let hier = FSNode(path: "/Users/tridiak/Documents/temp")
	hier.GatherChildren()
	
	print("******* Depth First Iteration")
	hier.Iterate(mode: .depthFirst)
	
	print("******* Depth First, Last First Iteration")
	hier.Iterate(mode: .depthFirstEnd)
	
	print("******* Breadth First Iteration")
	hier.Iterate(mode: .breadthFirst)
	
	print("******* Breadth First, Last First Iteration")
	hier.Iterate(mode: .breadthFirstEnd)
	
	print("******* All at depth 1");
	let A = hier.AllAtDepthDown(depth: 1)
	print(A)
	
	print("******* All at depth 2");
	let B = hier.AllAtDepthDown(depth: 2)
	print(B)
	
	print("*************************")
	let widest = hier.WidestRow()
	print("Widest row \(widest.row), \(widest.count) items")
	
	print("Depth \(hier.GreatestDepth())")
	
	print("**** Detach")
	let node = hier.firstChild!
	node.GoItAlone()
	print("\(node) detached")
	
	let nodes = hier.firstChild!.SiblingArray(setSortFlag: false)
	print(nodes)
	
	let detachedNode = hier.DetachChildren()!
	print("Detached node from hier")
	print("** Hier with no children")
	hier.Iterate(mode: .depthFirst)
	
	print("** Detached children")
	detachedNode.Iterate(mode: .depthFirst)
	
}
