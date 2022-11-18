//
//  SwiftUtilityAppTests.swift
//  SwiftUtilityAppTests
//
//  Created by tridiak on 28/06/22.
//  Copyright © 2022 tridiak. All rights reserved.
//

import XCTest

class SwiftUtilityAppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testStringStuff() throws {
		
		XCTAssertEqual("EFGH", "ABCDEFGH".RemoveFrom(set: CharacterSet(charactersIn: "ABCD")))
		XCTAssertEqual("EFGH", "ABCDEFGH".RemoveFrom(set: "ABCD"))
		var s = "ABCDEFGH"
		s.RemoveFromM(set: CharacterSet(charactersIn: "ABCD"))
		XCTAssertEqual(s, "EFGH")
		s = "ABCDEFGH"
		s.RemoveFromM(set: "ABCD")
		XCTAssertEqual(s, "EFGH")
		
		XCTAssertEqual("ABCD", "ABCDEFGH".KeepThoseIn(set: CharacterSet(charactersIn: "ABCD")))
		XCTAssertEqual("ABCD", "ABCDEFGH".KeepThoseIn(set: "ABCD"))
		s = "ABCDEFGH"
		s.KeepThoseInM(set: CharacterSet(charactersIn: "ABCD"))
		XCTAssertEqual(s, "ABCD")
		s = "ABCDEFGH"
		s.KeepThoseInM(set: "ABCD")
		XCTAssertEqual(s, "ABCD")
		
		//----------------------------------------------------------
		
		XCTAssertTrue("ABCDEFGH".OnlyContains(chars: CharacterSet.alphanumerics))
		XCTAssertFalse("ABCDEFGH".OnlyContains(chars: "ABCD"))
		
		//----------------------------------------------------------
		
		let rplstart = "A1B2C3D4E5"
		let rplend = "AXBXCXDXEX"
		XCTAssertEqual(rplend, rplstart.ReplaceAll(chars: CharacterSet.decimalDigits, with: "X"))
		XCTAssertEqual(rplend, rplstart.ReplaceAll(chars: "01234567890", with: "X"))
		s = rplstart
		s.ReplaceAllM(chars: CharacterSet.decimalDigits, with: "X")
		XCTAssertEqual(s, rplend)
		s = rplstart
		s.ReplaceAllM(chars: "01234567890", with: "X")
		XCTAssertEqual(s, rplend)
		
		//--------------------------------------------------
		
		let countA = "ABBCCCDDDDEEEEE"
		XCTAssertEqual(5, countA.CountOf(char: "E"))
		XCTAssertEqual(0, countA.CountOf(char: "Z"))
		
		//------------------------------------------------------
		
		let afterLast = "A.Beast.Nob.X/5"
		XCTAssertEqual(afterLast.StringAfterLast(char: "/"), "5")
		XCTAssertEqual(afterLast.StringAfterLast(char: "."), "X/5")
		XCTAssertNil(afterLast.StringAfterLast(char:"@"))
		
		XCTAssertEqual(afterLast.StringBeforeLast(char: "/"), "A.Beast.Nob.X")
		XCTAssertEqual(afterLast.StringBeforeLast(char: "."), "A.Beast.Nob")
		XCTAssertNil(afterLast.StringBeforeLast(char:"@"))
		
		//----------------------------------------------------
		
		let consecA = "AAABCCCDEEEFGGG"
		XCTAssertEqual(consecA.ReduceConsecutiveChars(), "ABCDEFG")
		s = consecA
		s.ReduceConsecutiveCharsM()
		XCTAssertEqual(s, "ABCDEFG")
		
		XCTAssertEqual(consecA.ReduceConsecutiveCharsOf(char:"C"), "AAABCDEEEFGGG")
		s = consecA
		s.ReduceConsecutiveCharsOfM(char: "C")
		XCTAssertEqual(s, "AAABCDEEEFGGG")
		
		//-------------------------------------------------------
		
		XCTAssertNil("111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111byte".ConvertSuffixedToUInt())
		XCTAssertNil("111111111111111111111111111111pib".ConvertSuffixedToUInt())
		XCTAssertNotNil("1.234pib".ConvertSuffixedToUInt())
		XCTAssertEqual("1.234byte".ConvertSuffixedToUInt(), 1)
		XCTAssertEqual("1.234tib".ConvertSuffixedToUInt(), 1356_7973_4867_5)
		XCTAssertEqual("1.234tb".ConvertSuffixedToUInt(), 1234_000_000_000)
		
		//--------------------------------------------------------
		
		let multipleString = "ABCABCABCABCABC"
		let notMultiple = "ABCABCABCABCA"
		
		XCTAssertNotNil(multipleString.EqualSplit(charCount: 3))
		XCTAssertEqual(multipleString.EqualSplit(charCount: 3)?.count, 5)
		XCTAssertNil(notMultiple.EqualSplit(charCount:3))
		
		//-----------------------------------------------------------
		
		let sameLevel = "A,B,C,[(D,E,F),(G,H)"
		XCTAssertNil(sameLevel.SameLevelSplit(separator: ",", upMarker: ",", downMarker: ")"))
		XCTAssertNil(sameLevel.SameLevelSplit(separator: ",", upMarker: "(", downMarker: ","))
		XCTAssertNil(sameLevel.SameLevelSplit(separator: ",", upMarker: "(", downMarker: "("))
		XCTAssertNil(sameLevel.SameLevelSplit(separator: ",", upMarker: "[", downMarker: "]"))
		let sameLevelRes = ["A", "B", "C", "[D,E,F", "G,H"]
		XCTAssertEqual(sameLevel.SameLevelSplit(separator: ",", upMarker: "(", downMarker: ")"), sameLevelRes)
		XCTAssertEqual("ABCD".SameLevelSplit(separator: ",", upMarker: "(", downMarker: ")"), ["ABCD"])
		
		//-----------------------------------------------------------
		let BAF = ":key=value=10-"
		var res = BAF.BeforeAndAfter(marker: "=")
		XCTAssertEqual(res.before, ":key")
		XCTAssertEqual(res.after, "value=10-")
		res = BAF.BeforeAndAfter(marker: ":")
		XCTAssertEqual(res.before, "")
		XCTAssertEqual(res.after, String(BAF.dropFirst()) )
		res = BAF.BeforeAndAfter(marker: "-")
		XCTAssertEqual(res.before, String(BAF.dropLast()) )
		XCTAssertEqual(res.after, "")
		
		//-----------------------------------------------------------
		
		let aaaValues : [String:UInt] = ["A":10, "AA":170, "AAA":2730, "AAAA":43690, "AAAAA":699050,
			"AAAAAA":11184810, "AAAAAAA":178956970, "AAAAAAAA":286_331_1530,
			"AAAAAAaaAAAAAAAA":12_297_829_382_473_034_410]
		
		for (K,V) in aaaValues {
			XCTAssertEqual(K.HexToUInt(), V)
		}
		
		XCTAssertNil("AAAAAAAAAAAAAAAAA".HexToUInt())
		XCTAssertNil("".HexToUInt())
		
		//-----------------------------------------------------------
		
		let nth = "ABCDEFGH"
		XCTAssertEqual(nth.GetChar(N: 3), "C")
		XCTAssertNil(nth.GetChar(N:-1))
		XCTAssertNil(nth.GetChar(N:20))
		
		XCTAssertEqual(nth.GetNthIndex(3), nth.index(nth.startIndex, offsetBy: 2))
		XCTAssertNil(nth.GetNthIndex(20))
		XCTAssertNil(nth.GetNthIndex(-1))
		
		//-----------------------------------------------------------
		
		s = "Add"
		s.AppendNotEmpty("Me")
		XCTAssertEqual(s, "AddMe")
		s = ""
		s.AppendNotEmpty("Me")
		XCTAssertEqual(s, "")
		
		//------------------------------------------------------------
		
		let part = "FirstAndLast"
		XCTAssertTrue(part.FirstPartIs("Fi"))
		XCTAssertFalse(part.FirstPartIs("And"))
		XCTAssertTrue(part.LastPartIs("st"))
		XCTAssertFalse(part.LastPartIs("And"))
		
		var partRes = part.FirstPartIsOne(of: ["Fi", "An", "st"])
		XCTAssertTrue(partRes.B)
		XCTAssertEqual(partRes.S, "Fi")
		partRes = part.FirstPartIsOne(of: ["An", "st"])
		XCTAssertFalse(partRes.B)
		XCTAssertNil(partRes.S)
		
		partRes = part.LastPartIsOne(of: ["Fi", "An", "st"])
		XCTAssertTrue(partRes.B)
		XCTAssertEqual(partRes.S, "st")
		partRes = part.LastPartIsOne(of: ["An", "Fi"])
		XCTAssertFalse(partRes.B)
		XCTAssertNil(partRes.S)
		
		//-----------------------------------------------------------
		
		let extTest = "A.Lot.of.ext.dots"
		let noExtTest = "NoExtDots"
		let firstDotTest = ".ext"
		let lastDotTest = "ext."
		
		var extRes = extTest.GetExtension()
		XCTAssertNotNil(extRes)
		XCTAssertEqual(extRes?.ext, "dots")
		XCTAssertEqual(extRes?.rem, "A.Lot.of.ext")
		
		extRes = noExtTest.GetExtension()
		XCTAssertNil(extRes)
		
		extRes = firstDotTest.GetExtension()
		XCTAssertNotNil(extRes)
		XCTAssertEqual(extRes?.ext, "ext")
		XCTAssertEqual(extRes?.rem, "")
		
		extRes = lastDotTest.GetExtension()
		XCTAssertNotNil(extRes)
		XCTAssertEqual(extRes?.ext, "")
		XCTAssertEqual(extRes?.rem, "ext")
		
		XCTAssertEqual(extTest.ChangeExtension(to: "bob"), "A.Lot.of.ext.bob")
		XCTAssertEqual(lastDotTest.ChangeExtension(to: "bob"), "ext.bob")
		XCTAssertEqual(firstDotTest.ChangeExtension(to: "bob"), ".bob")
		
		//-----------------------------------------------------------
		// Comparator operators
		let c : Character = "C"
		let d : Character = "D"
		s = "C"
		XCTAssertTrue(s == c)
		XCTAssertFalse(s == d)
		XCTAssertFalse(s != c)
		XCTAssertTrue(s != d)
		XCTAssertTrue(c == s)
		XCTAssertFalse(d == s)
		XCTAssertFalse(c != s)
		XCTAssertTrue(d != s)
		XCTAssertEqual(s + c, "CC")
		
		//------------------------------------------------------------
		// Arrat extensions
		let lengthArray = ["A", "BBB", "CC", "DDDD", "EEEE"]
		let lowerCaseAry = ["a", "bbb", "cc", "dddd", "eeee"]
		let emptyAry : [String] = []
		let longest = lengthArray.LongestString()
		XCTAssertNotNil(longest)
		XCTAssertEqual(longest?.index, 3)
		XCTAssertEqual(longest?.length, 4)
		XCTAssertNil(emptyAry.LongestString())
		
		XCTAssertEqual(lengthArray.LowerCaseAll(), lowerCaseAry)
		XCTAssertEqual(lengthArray, lowerCaseAry.UpperCaseAll())
		
		//-------------------------------------------------------------
		
		XCTAssertEqual(UInt(1.234).ByteString1000(), "1 byte")
		XCTAssertEqual(UInt(123.4).ByteString1000(), "123 byte")
		XCTAssertEqual(UInt(1234).ByteString1000(), "1.23 KB")
		XCTAssertEqual(UInt(123456).ByteString1000(), "123.46 KB")
		XCTAssertEqual(UInt(123456789).ByteString1000(), "123.46 MB")
		XCTAssertEqual(UInt.max.ByteString1000(), "18446.74 PB")
		
		XCTAssertEqual(UInt(1.234).ByteString1024(), "1 byte")
		XCTAssertEqual(UInt(123.4).ByteString1024(), "123 byte")
		XCTAssertEqual(UInt(1234).ByteString1024(), "1.21 KiB")
		XCTAssertEqual(UInt(123456).ByteString1024(), "120.56 KiB")
		XCTAssertEqual(UInt(123456789).ByteString1024(), "117.74 MiB")
		XCTAssertEqual(UInt.max.ByteString1024(), "16384.00 PiB")
	}
	
	func testPathClass() throws {
		let fullPath = "/Full/Len-gth/PathNoExt"
		
		//------------------------
		// Full path no extension
		var pc = PathClass(path: fullPath)!
		XCTAssertEqual(pc.path, fullPath)
		XCTAssertEqual(pc.dirMarker, "/")
		XCTAssertEqual(pc.AppendDirMarker().path, fullPath + "/")
		XCTAssertEqual(pc.RemoveDirMarker().path, fullPath)
		
		XCTAssertFalse(pc.isRelative)
		XCTAssertFalse(pc.LastCharIsMarker())
		XCTAssertTrue(pc.FirstCharIsMarker())
		
		// Prepend
		XCTAssertEqual(pc.Prepend(path: "/Hello").path, "/Hello" + fullPath)
		pc = PathClass(path: fullPath)!
		XCTAssertEqual(pc.Prepend(path: "/Hello/").path, "/Hello" + fullPath)
		pc = PathClass(path: fullPath)!
		XCTAssertEqual(pc.Prepend(path: "Hello/").path, "Hello" + fullPath)
		pc = PathClass(path: fullPath)!
		XCTAssertEqual(pc.Prepend(path: "Hello").path, "Hello" + fullPath)
		pc = PathClass(path: fullPath)!
		XCTAssertEqual(pc.Prepend(path: "").path, fullPath)
		pc = PathClass(path: fullPath)!
		XCTAssertEqual(pc.Prepend(path: "/").path, fullPath)
		
		// Append
		pc = PathClass(path: fullPath)!
		XCTAssertEqual(pc.Add(path: "/Hello").path, fullPath + "/Hello")
		pc = PathClass(path: fullPath)!
		XCTAssertEqual(pc.Add(path: "/Hello/").path, fullPath + "/Hello/")
		pc = PathClass(path: fullPath)!
		XCTAssertEqual(pc.Add(path: "Hello/").path, fullPath + "/Hello/")
		pc = PathClass(path: fullPath)!
		XCTAssertEqual(pc.Add(path: "Hello").path, fullPath + "/Hello")
		pc = PathClass(path: fullPath)!
		XCTAssertEqual(pc.Add(path: "").path, fullPath)
		pc = PathClass(path: fullPath)!
		XCTAssertEqual(pc.Add(path: "/").path, fullPath + "/")
		
		pc = PathClass(path: fullPath)!
		XCTAssertEqual(try? pc.RemoveSuffix().path, fullPath)
		// XCTAssertThrow
		
		pc = PathClass(path: fullPath)!
		XCTAssertEqual(pc.Components(), ["Full", "Len-gth", "PathNoExt"])
		XCTAssertEqual(pc.RemoveLastComponent().path, "/Full/Len-gth")
		
		pc = PathClass(path: fullPath)!
		XCTAssertEqual(pc.ConvertMarkers(marker: "-").path, "-Full-Len-gth-PathNoExt")
		XCTAssertEqual(pc.RemoveLastComponent().path, "-Full-Len-gth")
		
		pc = PathClass(path: fullPath)!
		XCTAssertEqual(pc.SwapDirMarkers(marker: "-").path, "-Full-Len/gth-PathNoExt")
		XCTAssertEqual(pc.RemoveLastComponent().path, "-Full-Len/gth")
		
		pc = PathClass(path: fullPath)!
		XCTAssertEqual(pc.ChangeDir(marker: "-").path, fullPath)
		XCTAssertEqual(pc.RemoveLastComponent().path, "/Full/Len")
		
		//-------------------------------------------------
		// Full path with extension
		let fullPathExt = "/Full/Len-gth/Path.Ext"
		
		pc = PathClass(path: fullPathExt)!
		XCTAssertEqual(pc.path, fullPathExt)
		XCTAssertEqual(pc.dirMarker, "/")
		XCTAssertEqual(pc.AppendDirMarker().path, fullPathExt + "/")
		XCTAssertEqual(pc.RemoveDirMarker().path, fullPathExt)
		
		XCTAssertFalse(pc.isRelative)
		XCTAssertFalse(pc.LastCharIsMarker())
		XCTAssertTrue(pc.FirstCharIsMarker())
		
		// Prepend
		XCTAssertEqual(pc.Prepend(path: "/Hello").path, "/Hello" + fullPathExt)
		pc = PathClass(path: fullPathExt)!
		XCTAssertEqual(pc.Prepend(path: "/Hello/").path, "/Hello" + fullPathExt)
		pc = PathClass(path: fullPathExt)!
		XCTAssertEqual(pc.Prepend(path: "Hello/").path, "Hello" + fullPathExt)
		pc = PathClass(path: fullPathExt)!
		XCTAssertEqual(pc.Prepend(path: "Hello").path, "Hello" + fullPathExt)
		pc = PathClass(path: fullPathExt)!
		XCTAssertEqual(pc.Prepend(path: "").path, fullPathExt)
		pc = PathClass(path: fullPathExt)!
		XCTAssertEqual(pc.Prepend(path: "/").path, fullPathExt)
		
		// Append
		pc = PathClass(path: fullPathExt)!
		XCTAssertEqual(pc.Add(path: "/Hello").path, fullPathExt + "/Hello")
		pc = PathClass(path: fullPathExt)!
		XCTAssertEqual(pc.Add(path: "/Hello/").path, fullPathExt + "/Hello/")
		pc = PathClass(path: fullPathExt)!
		XCTAssertEqual(pc.Add(path: "Hello/").path, fullPathExt + "/Hello/")
		pc = PathClass(path: fullPathExt)!
		XCTAssertEqual(pc.Add(path: "Hello").path, fullPathExt + "/Hello")
		pc = PathClass(path: fullPathExt)!
		XCTAssertEqual(pc.Add(path: "").path, fullPathExt)
		pc = PathClass(path: fullPathExt)!
		XCTAssertEqual(pc.Add(path: "/").path, fullPathExt + "/")
		
		pc = PathClass(path: fullPathExt)!
		XCTAssertEqual(try? pc.RemoveSuffix().path, "/Full/Len-gth/Path")
		// XCTAssertThrow
		
		pc = PathClass(path: fullPathExt)!
		XCTAssertEqual(pc.Components(), ["Full", "Len-gth", "Path.Ext"])
		XCTAssertEqual(pc.RemoveLastComponent().path, "/Full/Len-gth")
		
		pc = PathClass(path: fullPathExt)!
		XCTAssertEqual(pc.ConvertMarkers(marker: "-").path, "-Full-Len-gth-Path.Ext")
		XCTAssertEqual(pc.RemoveLastComponent().path, "-Full-Len-gth")
		
		pc = PathClass(path: fullPathExt)!
		XCTAssertEqual(pc.SwapDirMarkers(marker: "-").path, "-Full-Len/gth-Path.Ext")
		XCTAssertEqual(pc.RemoveLastComponent().path, "-Full-Len/gth")
		
		pc = PathClass(path: fullPathExt)!
		XCTAssertEqual(pc.ChangeDir(marker: "-").path, fullPathExt)
		XCTAssertEqual(pc.RemoveLastComponent().path, "/Full/Len")
		
		//----------------------------------------------------------------
		// Relative path
		let relativeDir = "Rel/Len-gth/Dir/"
		pc = PathClass(path: relativeDir)!
		
		XCTAssertEqual(pc.path, relativeDir)
		XCTAssertEqual(pc.dirMarker, "/")
		XCTAssertEqual(pc.AppendDirMarker().path, relativeDir)
		XCTAssertEqual(pc.RemoveDirMarker().path, "Rel/Len-gth/Dir")
		
		pc = PathClass(path: relativeDir)!
		XCTAssertTrue(pc.isRelative)
		XCTAssertTrue(pc.LastCharIsMarker())
		XCTAssertFalse(pc.FirstCharIsMarker())
		
		// Prepend
		XCTAssertEqual(pc.Prepend(path: "/Hello").path, "/Hello/" + relativeDir)
		pc = PathClass(path: relativeDir)!
		XCTAssertEqual(pc.Prepend(path: "/Hello/").path, "/Hello/" + relativeDir)
		pc = PathClass(path: relativeDir)!
		XCTAssertEqual(pc.Prepend(path: "Hello/").path, "Hello/" + relativeDir)
		pc = PathClass(path: relativeDir)!
		XCTAssertEqual(pc.Prepend(path: "Hello").path, "Hello/" + relativeDir)
		pc = PathClass(path: relativeDir)!
		XCTAssertEqual(pc.Prepend(path: "").path, relativeDir)
		pc = PathClass(path: relativeDir)!
		XCTAssertEqual(pc.Prepend(path: "/").path, "/" + relativeDir)
		
		// Append
		// "Rel/Len-gth/Dir/"
		pc = PathClass(path: relativeDir)!
		XCTAssertEqual(pc.Add(path: "/Hello").path, relativeDir + "Hello")
		pc = PathClass(path: relativeDir)!
		XCTAssertEqual(pc.Add(path: "/Hello/").path, relativeDir + "Hello/")
		pc = PathClass(path: relativeDir)!
		XCTAssertEqual(pc.Add(path: "Hello/").path, relativeDir + "Hello/")
		pc = PathClass(path: relativeDir)!
		XCTAssertEqual(pc.Add(path: "Hello").path, relativeDir + "Hello")
		pc = PathClass(path: relativeDir)!
		XCTAssertEqual(pc.Add(path: "").path, relativeDir)
		pc = PathClass(path: relativeDir)!
		XCTAssertEqual(pc.Add(path: "/").path, relativeDir)
		
		pc = PathClass(path: relativeDir)!
		XCTAssertEqual(try? pc.RemoveSuffix().path, relativeDir)
		// XCTAssertThrow
		
		pc = PathClass(path: relativeDir)!
		XCTAssertEqual(pc.Components(), ["Rel", "Len-gth", "Dir"])
		XCTAssertEqual(pc.RemoveLastComponent().path, "Rel/Len-gth")
		
		pc = PathClass(path: relativeDir)!
		XCTAssertEqual(pc.ConvertMarkers(marker: "-").path, "Rel-Len-gth-Dir-")
		XCTAssertEqual(pc.RemoveLastComponent().path, "Rel-Len-gth")
		
		pc = PathClass(path: relativeDir)!
		XCTAssertEqual(pc.SwapDirMarkers(marker: "-").path, "Rel-Len/gth-Dir-")
		XCTAssertEqual(pc.RemoveLastComponent().path, "Rel-Len/gth")
		
		pc = PathClass(path: relativeDir)!
		XCTAssertEqual(pc.ChangeDir(marker: "-").path, relativeDir)
		XCTAssertEqual(pc.RemoveLastComponent().path, "Rel/Len")
		
		//----------------------------------------------------------------
		// Comparison operators
		let relativePath = "Rel/Len-gth/PathNoExt"
		pc = PathClass(path: fullPath)!
		let pc2 = PathClass(path: fullPath)!
		let pc3 = PathClass(path: relativePath)!
		XCTAssertTrue(pc == pc2)
		XCTAssertTrue(pc == pc2.RemoveDirMarker())
		XCTAssertFalse(pc == pc3)
		XCTAssertTrue(pc != pc3)
		pc--
		XCTAssertEqual(pc, pc2.RemoveLastComponent())
		
		XCTAssertEqual(pc2[0], "Full")
		XCTAssertEqual(pc2[1], "Len-gth")
		XCTAssertEqual(pc2[444], nil)
	}
	
	func testZTextFile() throws {
		// /Users/tridiak/Documents/AD&D/SpellsDBFiles/EditCopy.txt
		// Users/tridiak/Documents/spell_full-SR.csv
		let smallFile = "/Users/tridiak/Documents/AD&D/SpellsDBFiles/MaximiseEmpowerSpells.txt"
		let bigFile = "/Users/tridiak/Documents/AD&D/SpellsDBFiles/magic_items_full.tsv"
		let emptyFile = "/Users/tridiak/Documents/AD&D/SpellsDBFiles/Empty.txt"
		let oneCharFile = "/Users/tridiak/Documents/AD&D/SpellsDBFiles/1Char.txt"
		
		let smallSmallTF = ZTextFile(path: smallFile)
		XCTAssertNotNil(smallSmallTF)
		XCTAssertEqual(smallSmallTF!.lineCount, 470)
		
		XCTAssertEqual(smallSmallTF![7]!, "Aggressive Thundercloud, Greater")
		XCTAssertNil(smallSmallTF![smallSmallTF!.lineCount])
		
		let bigSmallTF = ZTextFile(path: bigFile, linefeed: .windows)
		XCTAssertNotNil(bigSmallTF)
		XCTAssertEqual(bigSmallTF!.lineCount, 4242)
		var l = bigSmallTF![1793]!
		XCTAssertEqual(l, "Eyes Of Blindness\tfaint necromancy\t5\teyes\t\t-\tThese normal-looking glasses appear harmless and nondescript. When they are worn, the wearer becomes blinded as if subject to the blindness/deafness spell (no saving throw).\t\t\tCursed\tUltimate Equipment\t\t\t\t\t\t\t\t\tAny glasses or lenses\t<link rel=\"stylesheet\"href=\"PF.css\"><div class=\"heading\"><p class=\"alignleft\">Eyes Of Blindness</p><div style=\"clear: both;\"></div></div><div><h5><b>Aura </b>faint necromancy; <b>CL </b>5th</h5><h5><b>Slot </b>eyes; <b>Weight </b>-</h5></div><hr/><div><h5><b>DESCRIPTION</b></h5></div><hr/><div><h4><p>These normal-looking glasses appear harmless and nondescript. When they are worn, the wearer becomes blinded as if subject to the <i>blindness/deafness</i> spell (no saving throw).</p></h4></div><hr/><div><h5><b>CREATION</b></h5></div><hr/><div><h5><b>Magic Items </b>Any glasses or lenses</h5></div>\t\t0\t0\t0\t0\t0\t0\t0\t1\t0\tfaint\t0\t0\t0\t\t\tNULL\t2549\t0\t0\t0\t0\t\t0")
		
		//----------------------------------------
		let smallBigTF = ZBigTextFile(path: smallFile)
		
		XCTAssertNotNil(smallBigTF)
		XCTAssertEqual(smallBigTF!.lineCount, 470)
		
		
		XCTAssertEqual(smallBigTF![7]!, "Aggressive Thundercloud, Greater")
		XCTAssertNil(smallBigTF![smallSmallTF!.lineCount])
		
		let bigBigTF = ZBigTextFile(path: bigFile, linefeed: .windows)
		XCTAssertNotNil(bigBigTF)
		XCTAssertEqual(bigBigTF!.lineCount, 4242)
		l = bigBigTF![1793]!
		XCTAssertEqual(l, "Eyes Of Blindness\tfaint necromancy\t5\teyes\t\t-\tThese normal-looking glasses appear harmless and nondescript. When they are worn, the wearer becomes blinded as if subject to the blindness/deafness spell (no saving throw).\t\t\tCursed\tUltimate Equipment\t\t\t\t\t\t\t\t\tAny glasses or lenses\t<link rel=\"stylesheet\"href=\"PF.css\"><div class=\"heading\"><p class=\"alignleft\">Eyes Of Blindness</p><div style=\"clear: both;\"></div></div><div><h5><b>Aura </b>faint necromancy; <b>CL </b>5th</h5><h5><b>Slot </b>eyes; <b>Weight </b>-</h5></div><hr/><div><h5><b>DESCRIPTION</b></h5></div><hr/><div><h4><p>These normal-looking glasses appear harmless and nondescript. When they are worn, the wearer becomes blinded as if subject to the <i>blindness/deafness</i> spell (no saving throw).</p></h4></div><hr/><div><h5><b>CREATION</b></h5></div><hr/><div><h5><b>Magic Items </b>Any glasses or lenses</h5></div>\t\t0\t0\t0\t0\t0\t0\t0\t1\t0\tfaint\t0\t0\t0\t\t\tNULL\t2549\t0\t0\t0\t0\t\t0")
		
		//----------------------------------------
		// Use BBEdit to change and add LF to one char file. Change linefeed: parameter.
		let emptySmallTF = ZTextFile(path: emptyFile, linefeed: .unix)
		XCTAssertNotNil(emptySmallTF)
		XCTAssertEqual(emptySmallTF!.lineCount, 0)
		XCTAssertNil(emptySmallTF![0])
		
		//----------------------------------------
		
		let oneCharSmallTF = ZTextFile(path: oneCharFile)
		XCTAssertNotNil(oneCharSmallTF)
		XCTAssertEqual(oneCharSmallTF!.lineCount, 1)
		XCTAssertNotNil(oneCharSmallTF![0])
	}
	
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
