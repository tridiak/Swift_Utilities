//
//  PosNeg.swift
//  Swift-Utilities
//
//  Created by tridiak on 9/12/18.
//  Copyright © 2018 tridiak. All rights reserved.
//

import Foundation

//enum PosNegEx : Error {
//	case nonsensical
//	case subclass
//}

public protocol PosNegP : CustomStringConvertible {
	
	var value : Int { get }
	var name : String  { get }
	
	func IsPositive() -> Bool
	func IsNegative() -> Bool
	func IsZero() -> Bool
	
	func P() -> Bool
	func N() -> Bool
	func Z() -> Bool
	
	func Mx(RHS : PosNegP) -> PosNegP
	func Dv(RHS : PosNegP) -> PosNegP?
	func Ad(RHS : PosNegP) -> PosNegP?
	func Ms(RHS : PosNegP) -> PosNegP?
	
	func LT(RHS : PosNegP) -> Bool
	func GT(RHS : PosNegP) -> Bool
	func EQ(RHS : PosNegP) -> Bool
	func NE(RHS : PosNegP) -> Bool
	
	func Inc() -> PosNegP
	func Dec() -> PosNegP
	
	func Ng() -> PosNegP
}

//---------------------------------------------------
// MARK: Accessors

public func PosNegCreate<T : Numeric & Comparable>(value V: T) -> PosNegP {
	if V < 0 { return negative }
	else if V > 0 { return positive }
	
	return zero
}

public func GetNegative() -> PosNegP { return negative }

public func GetPositive() -> PosNegP { return positive }

public func GetZero() -> PosNegP { return zero }

//---------------------------------------------------
// MARK: Operators

func * (LHS : PosNegP, RHS : PosNegP) -> PosNegP {
	return LHS.Mx(RHS: RHS)
}

func / (LHS : PosNegP, RHS : PosNegP) -> PosNegP? {
	return LHS.Dv(RHS: RHS)
}

func + (LHS : PosNegP, RHS : PosNegP) -> PosNegP? {
	return LHS.Ad(RHS: RHS)
}

func - (LHS : PosNegP, RHS : PosNegP) -> PosNegP? {
	return LHS.Ms(RHS: RHS)
}

func < (LHS : PosNegP, RHS : PosNegP) -> Bool {
	return LHS.LT(RHS: RHS)
}

func > (LHS : PosNegP, RHS : PosNegP) -> Bool {
	return LHS.GT(RHS: RHS)
}

func == (LHS : PosNegP, RHS : PosNegP) -> Bool {
	return LHS.EQ(RHS: RHS)
}

func != (LHS : PosNegP, RHS : PosNegP) -> Bool {
	return LHS.NE(RHS: RHS)
}

prefix func ! (LHS : PosNegP) -> PosNegP {
	return LHS.Ng()
}

postfix func ++ (LHS : PosNegP) -> PosNegP {
	return LHS.Inc()
}

postfix func -- (LHS : PosNegP) -> PosNegP {
	return LHS.Dec()
}

func * (LHS : Int, RHS : PosNegP) -> Int {
	return LHS * RHS.value
}

func / (LHS : Int, RHS : PosNegP) -> Int {
//	if RHS.Z() { return 0 }
	return LHS / RHS.value
}

func * (LHS : Double, RHS : PosNegP) -> Double {
	return LHS * Double(RHS.value)
}

func / (LHS : Double, RHS : PosNegP) -> Double {
//	if RHS.Z() { return 0 }
	return LHS / Double(RHS.value)
}

//---------------------------------------------
// MARK:- Zero

fileprivate let zero = PNZero()

fileprivate struct PNZero : PosNegP {
	var description: String { return name }
	
	var value: Int { return 0 }
	
	var name: String { return "Zero" }
	
	func IsPositive() -> Bool { return false }
	
	func IsNegative() -> Bool { return false }
	
	func IsZero() -> Bool { return true }
	
	func P() -> Bool { return IsPositive() }
	
	func N() -> Bool { return IsNegative() }
	
	func Z() -> Bool { return IsZero() }
	
	func Mx(RHS: PosNegP) -> PosNegP {
		return zero
	}
	
	func Dv(RHS: PosNegP) -> PosNegP? {
		if RHS.Z() { return nil }
		return zero
	}
	
	func Ad(RHS: PosNegP) -> PosNegP? {
		return RHS
	}
	
	func Ms(RHS: PosNegP) -> PosNegP? {
		return RHS.Ng()
	}
	
	func LT(RHS: PosNegP) -> Bool {
		return RHS.P()
	}
	
	func GT(RHS: PosNegP) -> Bool {
		return RHS.N()
	}
	
	func EQ(RHS: PosNegP) -> Bool {
		return RHS.Z()
	}
	
	func NE(RHS: PosNegP) -> Bool {
		return !RHS.Z()
	}
	
	func Ng() -> PosNegP {
		return zero
	}
	
	func Inc() -> PosNegP {
		return positive
	}
	
	func Dec() -> PosNegP {
		return negative
	}
}

//---------------------------------------------
// MARK:- Positive

fileprivate let positive = PNPositive()

fileprivate struct PNPositive : PosNegP {
	var description: String { return name }
	
	var value: Int { return 1 }
	
	var name: String { return "Positive" }
	
	func IsPositive() -> Bool {
		return true
	}
	
	func IsNegative() -> Bool {
		return false
	}
	
	func IsZero() -> Bool {
		return false
	}
	
	func P() -> Bool {
		return IsPositive()
	}
	
	func N() -> Bool {
		return IsNegative()
	}
	
	func Z() -> Bool {
		return IsZero()
	}
	
	func Mx(RHS: PosNegP) -> PosNegP {
		return RHS
	}
	
	func Dv(RHS: PosNegP) -> PosNegP? {
		if RHS.Z() { return nil }
		return RHS
	}
	
	func Ad(RHS: PosNegP) -> PosNegP? {
		if RHS.N() { return nil }
		return positive
	}
	
	func Ms(RHS: PosNegP) -> PosNegP? {
		if RHS.P() { return nil }
		return positive
	}
	
	func LT(RHS: PosNegP) -> Bool {
		return false
	}
	
	func GT(RHS: PosNegP) -> Bool {
		return !RHS.P()
	}
	
	func EQ(RHS: PosNegP) -> Bool {
		return RHS.P()
	}
	
	func NE(RHS: PosNegP) -> Bool {
		return !RHS.P()
	}
	
	func Inc() -> PosNegP {
		return positive
	}
	
	func Dec() -> PosNegP {
		return zero
	}
	
	func Ng() -> PosNegP {
		return negative
	}
	

}

//---------------------------------------------
// MARK:- Negative

fileprivate let negative = PNNegative()

fileprivate struct PNNegative : PosNegP {
	var description: String { return name }
	
	var value: Int { return -1 }
	
	var name: String { return "Negative" }
	
	func IsPositive() -> Bool {
		return false
	}
	
	func IsNegative() -> Bool {
		return true
	}
	
	func IsZero() -> Bool {
		return  false
	}
	
	func P() -> Bool {
		return IsPositive()
	}
	
	func N() -> Bool {
		return IsNegative()
	}
	
	func Z() -> Bool {
		return IsZero()
	}
	
	func Mx(RHS: PosNegP) -> PosNegP {
		return RHS.Ng()
	}
	
	func Dv(RHS: PosNegP) -> PosNegP? {
		if RHS.Z() { return nil }
		return RHS.Ng()
	}
	
	func Ad(RHS: PosNegP) -> PosNegP? {
		if RHS.P() { return nil }
		return negative
	}
	
	func Ms(RHS: PosNegP) -> PosNegP? {
		if RHS.N() { return nil }
		return negative
	}
	
	func LT(RHS: PosNegP) -> Bool {
		return !RHS.N()
	}
	
	func GT(RHS: PosNegP) -> Bool {
		return false
	}
	
	func EQ(RHS: PosNegP) -> Bool {
		return RHS.N()
	}
	
	func NE(RHS: PosNegP) -> Bool {
		return !RHS.N()
	}
	
	func Inc() -> PosNegP {
		return zero
	}
	
	func Dec() -> PosNegP {
		return negative
	}
	
	func Ng() -> PosNegP {
		return positive
	}
	

}
