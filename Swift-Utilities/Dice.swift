//
//  Dice.swift
//  dragonGen
//
//  Created by tridiak on 3/01/17.
//  Copyright © 2017 tridiak. All rights reserved.
//

import Foundation

enum DiceError : Error {
	case unknownDiceFormat
	case zeroError
	}

struct Dice : Equatable, CustomDebugStringConvertible {
	var X : UInt
	var Y : UInt
	var Z : Int
	init(diceString : String) throws {
		var s = diceString.lowercased()
		let r = s
		s.ReplaceAllM(chars: "0123456789", with: "X")
		switch s {
			case "XdX":
				let ary = r.components(separatedBy: "d")
				X = UInt(ary[0])!
				Y = UInt(ary[1])!
				Z = 0
			case "XdX+X":
				let B = r.BeforeAndAfter(separator: "d")
				X = UInt(B.before)!
				let C = B.after!.BeforeAndAfter(separator: "+")
				Y = UInt(C.before)!
				Z = Int(C.after!)!
			case "XdX-X":
				let B = r.BeforeAndAfter(separator: "d")
				X = UInt(B.before)!
				let C = B.after!.BeforeAndAfter(separator: "-")
				Y = UInt(C.before)!
				Z = -Int(C.after!)!
			case "dX":
				s = String(r[r.index(after: r.startIndex)...])
				X = 1
				Y = UInt(s)!
				Z = 0
				break
			case "dX+X":
				s = String(r[r.index(after: r.startIndex)...])
				let R = s.BeforeAndAfter(separator: "+")
				X = 1
				Y = UInt(R.before)!
				Z = Int(R.after!)!
				break
			case "dX-X":
				s = String(r[r.index(after: r.startIndex)...])
				let R = s.BeforeAndAfter(separator: "-")
				X = 1
				Y = UInt(R.before)!
				Z = -Int(R.after!)!
				break
			case "X":
				X = 0
				Y = 0
				Z = Int(r)!
			default:
				throw DiceError.unknownDiceFormat
			}
		}
	
	init(_ x : UInt = 1,_ y : UInt,_ z : Int = 0) {
		X = x
		Y = y
		Z = z
		}
	
	/// Roll Xdy±Z. Calls through to RollXdYpZ()
	func Roll() -> Int {
		return Dice.RollXdYpZ(X: X, Y: Y, Z: Z)
		}
	
	/// Roll XdY drop Z. If Z < 0, 0 will be returned.
	/// This can never return a -ve value. Calls through to RollXdYdropZ()
	func RollDropZ() -> UInt {
		if Z < 0 {return 0}
		
		return Dice.RollXdYdropZ(X: X, Y: Y, Z: UInt(Z))
	}
	
	/// Roll XdY drop Z
	static func RollXdYdropZ(X:UInt, Y:UInt, Z:UInt) -> UInt {
		if Z >= X || Z > Int.max { return 0 }
		if X == 0 || Y == 0 { return Z }
		if Y == 1 {return X - Z }
		
		var rolls : [UInt] = []
		
		for _ in 1...X {
			let r = UInt(arc4random()) % Y + 1
			rolls.append(r)
		}
		
		rolls.sort(by: >)
		rolls.removeLast(Int(Z))
		return rolls.reduce(0, +)
	}
	
	/// Roll XdY±Z
	static func RollXdYpZ(X:UInt, Y:UInt, Z:Int) -> Int {
		var r : UInt = 0
		var total : Int = 0
		for _ in 0 ..< X {
			r = (UInt(arc4random()) % Y) + 1
			total += Int(r)
			}
		total += Z
		
		return total
	}
	
	/// Multiple X by M
	static func * (d : Dice, m : UInt) -> Dice {
		return Dice(d.X * m, d.Y, d.Z)
		}
	
	func Description() -> String {
		var s : String = ""
		if X > 1 {s = s + String(X)}
		s = s + "d\(Y)"
		if Z != 0 {
			s = s + (Z < 0 ? "" : "+")
			s = s + String(Z)
			}
		return s
		}
	
	var debugDescription: String {
		get {
			return self.Description()
			}
		}
	
	static func == (d1 : Dice, d2 : Dice) -> Bool {
		return d1.X == d2.X && d1.Y == d2.Y && d1.Z == d2.Z
		}
	
	static func != (d1 : Dice, d2 : Dice) -> Bool {
		return !(d1.X == d2.X && d1.Y == d2.Y && d1.Z == d2.Z)
		}
}

let D1 = Dice(0,0,1)
let D2 = Dice(1,2,0)
let D3 = Dice(1,3,0)
let D4 = Dice(1,4,0)
let D6 = Dice(1,6,0)
let D8 = Dice(1,8,0)
let D10 = Dice(1,10,0)
let D12 = Dice(1,12,0)
let D20 = Dice(1,20,0)
let D100 = Dice(1,100,0)

//-----------------------------------------------------
// MARK:-

func Roll4d6Drop1() -> [UInt8] {
	let D = Dice(4,6,1)
	
	var a : [UInt8] = []
	for _ in 1...6 {
		a.append(UInt8(D.RollDropZ()) )
	}
	
	return a
}

func Roll3d6() -> [UInt8] {
	let D = Dice(3,6,0)
	
	var a : [UInt8] = []
	for _ in 1...6 {
		a.append(UInt8(D.Roll()) )
	}
	
	return a
}
