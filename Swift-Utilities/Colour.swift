//
//  Colour.swift
//  Swift-Utilities
//
//  Created by tridiak on 8/12/18.
//  Copyright © 2018 tridiak. All rights reserved.
//

import Cocoa

// Using Int16 instead of UInt8 because in future may allow
// ranges outside of 0-1
typealias Col8 = Int16

// Colour class for colour amateurs like me.
// Handles colour conversion.
// The colour is stored as RGB regardless of what colour space is passed to
// the constructors.
struct Colour : CustomStringConvertible {
	var description: String {
		return HexString(prefix: "&", inclAlpha: false)
	}
	
	struct ColInfo : CustomStringConvertible {
		var description: String {
			return String(format: "%.2f, %.2f, %.2f, %.2f", V0, V1, V2, V3)
		}
		
		var V0 : Float // R, C, H
		var V1 : Float // G, M, S
		var V2 : Float // B, Y, V
		var V3 : Float // -, K, -
		
		subscript(idx : Int) -> Float? {
			switch idx {
				case 0: return V0
				case 1: return V1
				case 2: return V2
				case 3: return V3
				default: return nil
			}
		}
		
		var R : Float {
		 	get { return V0 }
			set(V) { V0 = V }
		}
		var G : Float {
		 	get { return V1 }
			set(V) { V1 = V }
		}
		var B : Float {
		 	get { return V2 }
			set(V) { V2 = V }
		}
		
		var C : Float {
		 	get { return V0 }
			set(V) { V0 = V }
		}
		var M : Float {
		 	get { return V1 }
			set(V) { V1 = V }
		}
		var Y : Float {
		 	get { return V2 }
			set(V) { V2 = V }
		}
		var K : Float {
		 	get { return V3 }
			set(V) { V3 = V }
		}
		
		var H : Float {
		 	get { return V0 }
			set(V) { V0 = V }
		}
		var S : Float {
		 	get { return V1 }
			set(V) { V1 = V }
		}
		var V : Float {
		 	get { return V2 }
			set(V) { V2 = V }
		}
	} // ColInfo
	
	//------------------------
	
	private var rgb : ColInfo
	private(set) var alpha : Float
	
	// Ensure all values are 0-1 (except for Hue, its range is 0-360)
	mutating private func Constrain(V : inout Float) {
		if V < 0 { V = 0 }
		else if V > 1 { V = 1 }
	}
	
	mutating private func Constrain() {
		var c = rgb
		Constrain(V:&c.V0)
		Constrain(V:&c.V1)
		Constrain(V:&c.V2)
		Constrain(V:&c.V3)
		rgb = c
	}
	
	mutating private func ConstrainAlpha() {
		var Z = alpha
		Constrain(V:&Z)
		alpha = Z
	}
	
	//-------------------------------------------------
	// MARK:- Constructors
	
	init() {
		rgb = ColInfo(V0: 0, V1: 0, V2: 0, V3: 0)
		alpha = 1
	}
	
	init(red: Float, green: Float, blue : Float, alpha A : Float = 1) {
		rgb = ColInfo(V0: red, V1: green, V2: blue, V3: 0)
		alpha = A
		
		Constrain()
		ConstrainAlpha()
	}
	
	init(red: Col8, green: Col8, blue : Col8, alpha A : Col8 = 255) {
		self.init(red: Float(red) / 255, green: Float(green) / 255,
			blue: Float(blue) / 255, alpha: Float(A) / 255)
		
		Constrain()
		ConstrainAlpha()
	}
	
	enum NamedColour {
		case white
		case black
		case red
		case green
		case blue
		case cyan
		case magenta
		case yellow
		case lightGray
		case darkGray
		case gray
		
		func RGB() -> (R:Float, G:Float, B:Float) {
			switch self {
				case .white:
					return (1,1,1)
				case .black:
					return (0,0,0)
				case .red:
					return (1,0,0)
				case .green:
					return (0,1,0)
				case .blue:
					return (0,0,1)
				case .cyan:
					return (0,1,1)
				case .magenta:
					return (1,0,1)
				case .yellow:
					return (1,1,0)
				case .lightGray:
					return (0.75, 0.75, 0.75)
				case .darkGray:
					return (0.25, 0.25, 0.25)
				case .gray:
					return (0.5, 0.5, 0.5)
			}
		} // RGB()
	}
	
	init(named: NamedColour) {
		let v = named.RGB()
		self.init(red: v.R, green: v.G, blue: v.B, alpha: 1)
	}
	
	init(grayScale: Float) {
		self.init(red: grayScale, green: grayScale, blue: grayScale, alpha: 1)
	}
	
	init?(cyan: Float, magenta: Float, yellow:Float, black:Float, alpha A: Float) {
		let cmyk = ColInfo(V0: cyan, V1: magenta, V2: yellow, V3: black)
		// TEST when nil returned
		self.init(colSpace: .CMYK, colour: cmyk)
		alpha = A
	}
	
	init?(hue: Float, sat: Float, value: Float, alpha A: Float) {
		let hsv = ColInfo(V0: hue, V1: sat, V2: value, V3: 0)
		
		self.init(colSpace: .HSV, colour: hsv)
		alpha = A
	}
	
	enum ColSpace {
		case RGB
		case CMYK
		case HSV
	}
	
	init?(colSpace : ColSpace, colour: ColInfo) {
		alpha = 1
		switch colSpace {
			case .RGB:
				rgb = colour
			case .CMYK:
				guard let RGB = Colour.CMYKtoRGB(cmyk: colour) else { return nil }
				rgb = RGB
			case .HSV:
				guard let RGB = Colour.HSVtoRGB(hsv: colour) else { return nil }
				rgb = RGB
		}
		Constrain()
	}
	
	/// See HexString(). Assumes no prefix.
	init?(hexString: String) {
		let len = hexString.count
		if len != 6 && len != 8 { return nil }
		
		let ary = hexString.EqualSplit(charCount: 2)!
		
		guard let R = ary[0].HexToUInt() else { return nil }
		guard let G = ary[1].HexToUInt() else { return nil }
		guard let B = ary[2].HexToUInt() else { return nil }
		guard let A = len == 8 ? ary[0].HexToUInt() : 255 else { return nil }
		
		rgb = ColInfo(V0: Float(R) / 255, V1: Float(G) / 255, V2: Float(B) / 255, V3: 0)
		alpha = Float(A) / 255
	}
	
	//--------------------------------------------------------------
	// MARK:- Accessors
	
	var RGB : ColInfo {	return rgb }
	
	var CMYK : ColInfo { return Colour.RGBtoCMYK(rgb: rgb)! }
	
	var HSV : ColInfo { return Colour.RGBtoHSV(rgb: rgb)! }
	
	var red : Float { return rgb.R }
	var green : Float { return rgb.G }
	var blue : Float { return rgb.B }
	
	var cyan : Float { return CMYK.C }
	var magenta : Float { return CMYK.M }
	var yellow : Float { return CMYK.Y }
	var black : Float { return CMYK.K }
	
	var hue : Float { return HSV.H }
	var saturation : Float { return HSV.S }
	var brightness : Float { return HSV.V }
	
	var gray : Float { return (rgb.R + rgb.G + rgb.B) / 3 }
	
	mutating func LightDark(mult : Float) {
		rgb.R *= mult
		rgb.G *= mult
		rgb.B *= mult
		
		Constrain()
	}
	
	//-------------------------------------------------------------
	// MARK:- As String
	
	// Returns "<prefix>RRGGBB(AA)"
	func HexString(prefix: String, inclAlpha: Bool) -> String {
		var s : String = ""
		s.append(prefix)
		// CHECK
		s = s.appendingFormat("%X", Col8(rgb.R * 255) )
		s = s.appendingFormat("%X", Col8(rgb.G * 255) )
		s = s.appendingFormat("%X", Col8(rgb.B * 255) )
		if inclAlpha {
			s = s.appendingFormat("%X", Col8(alpha * 255) )
		}
		
		return s
	}
	
	// Returns ["RR", "GG", "BB"(, "AA")]
	func HexString(inclAlpha: Bool) -> [String] {
		var s : [String] = Array(repeating: "", count: inclAlpha ? 4 : 3)
		
		s[0] = String(format: "%X", Col8(rgb.R * 255))
		s[1] = String(format: "%X", Col8(rgb.G * 255))
		s[2] = String(format: "%X", Col8(rgb.B * 255))
		if inclAlpha {
			s[3] = String(format: "%X", Col8(alpha * 255))
		}
		
		return s
	}
	
	//--------------------------------------------------------------
	// MARK:- Static Converters
	
	private static func OutOfRangeHSV(hsv: ColInfo) -> Bool {
		if hsv.H < 0 || hsv.H > 360 { return false }
		for idx in 1...3 {
			if hsv[idx]! < 0.0 || hsv[idx]! > 1.0 { return false }
		}
		return true
	}
	
	private static func OutOfRange(col: ColInfo) -> Bool {
		for idx in 0...3 {
			if col[idx]! < 0 || col[idx]! > 1 { return false }
		}
		return true
	}
	
	static func RGBtoCMYK(rgb : ColInfo) -> ColInfo? {
		if !OutOfRange(col: rgb) { return nil }
		
		let max = rgb.R > rgb.G ? rgb.R : (rgb.G > rgb.B ? rgb.G : rgb.B)
		
		var cmyk = ColInfo.init(V0: 0, V1: 0, V2: 0, V3: 0)
		cmyk.K = 1 - max
		cmyk.C = (1 - rgb.R - cmyk.K) / (1 - cmyk.K)
		cmyk.M = (1 - rgb.G - cmyk.K) / (1 - cmyk.K)
		cmyk.Y = (1 - rgb.B - cmyk.K) / (1 - cmyk.K)
		
		return cmyk
	}
	
	static func CMYKtoRGB(cmyk : ColInfo) -> ColInfo? {
		if !OutOfRange(col: cmyk) { return nil }
		
		var rgb = ColInfo.init(V0: 0, V1: 0, V2: 0, V3: 0)
		
		rgb.R = (1 - cmyk.C) * (1 - cmyk.K)
		rgb.G = (1 - cmyk.M) * (1 - cmyk.K)
		rgb.B = (1 - cmyk.Y) * (1 - cmyk.K)
		
		return rgb
	}
	
	static func RGBtoHSV(rgb : ColInfo) -> ColInfo? {
		if !OutOfRange(col: rgb) { return nil }
		
		let min = rgb.R < rgb.G ? rgb.R : (rgb.G < rgb.B ? rgb.G : rgb.B)
		let max = rgb.R > rgb.G ? rgb.R : (rgb.G > rgb.B ? rgb.G : rgb.B)
		
		var hsv = ColInfo(V0: 0, V1: 0, V2: 0, V3: 0)
		
		hsv.V = max
		let delta = max - min
		
		if max != 0 { hsv.S = delta / max }
		else { // B is undefined
			hsv.S = 0
			hsv.H = 0
		}
		
		if !(rgb.R < max) {
			hsv.H = (rgb.G - rgb.B) / delta
		}
		else if !(rgb.G < max) {
			hsv.H = 2 + (rgb.B - rgb.R) / delta
		}
		else {
			hsv.H = 4 + (rgb.R - rgb.G) / delta
		}
		
		hsv.H *= 60
		while (hsv.H < 0) { hsv.H += 360 }
		
		return hsv
	}
	
	static func HSVtoRGB(hsv : ColInfo) -> ColInfo? {
		if !OutOfRangeHSV(hsv: hsv) { return nil }
		
		let H = hsv.H
		let C = hsv.V * hsv.S
		let X = C * (1 - fabsf( fmodf(H / 60, 2) - 1))
		let m = hsv.V - C
		var R : Float = 0
		var G : Float = 0
		var B : Float = 0
		
		if H < 60 {
			R = C
			G = X
		}
		else if H < 120 {
			R = X
			G = C
		}
		else if H < 180 {
			G = C
			B = X
		}
		else if H < 240 {
			G = X
			B = C
		}
		else if H < 300 {
			R = X
			B = X
		}
		else {
			R = C
			B = X
		}
		
		let rgb = ColInfo.init(V0: R + m, V1: G + m, V2: B + m, V3: 0)
		
		return rgb
	}
	
	static func CMYKtoHSV(cmyk: ColInfo) -> ColInfo? {
		guard let rgb = CMYKtoRGB(cmyk: cmyk) else { return nil }
		return RGBtoHSV(rgb:rgb)
	}
	
	static func HSVtoCMYK(hsv: ColInfo) -> ColInfo? {
		guard let rgb = HSVtoRGB(hsv: hsv) else { return nil }
		return RGBtoCMYK(rgb:rgb)
	}
}


//---------------------------------------------------------
// MARK:-

extension NSColor {
	/// Returns colour as a hex string. Note: colour range can extend outside of 0-1. If any RGB component
	/// does, nil will be returned. If the colour space cannot be converted to RGB, nil will be
	/// returned.
	func AsRGBString(prefix: String = "&", inclAlpha: Bool = false) -> String? {
		var colS = prefix
		
		guard let colRGB = self.usingColorSpace(NSColorSpace.genericRGB) else { return nil }
		
		let R = Int16(colRGB.redComponent * 100)
		let G = Int16(colRGB.greenComponent * 100)
		let B = Int16(colRGB.blueComponent * 100)
		
		if R < 0 || R > 255 || G < 0 || G > 255 || B < 0 || B > 255 { return nil }
		
		colS += String(format: "%02X", R)
		colS += String(format: "%02X", G)
		colS += String(format: "%02X", B)
		
		if inclAlpha {
			let A = Int16(colRGB.alphaComponent * 100)
			if A < 0 || A > 255 { return nil }
			colS += String(format: "%02X", A)
		}
		
		return colS
	}
	
	/// Returns colour as a hex string. Note: colour range can extend outside of 0-1. If any CYMK component
	/// does, nil will be returned. If the colour space cannot be converted to CYMK, nil will be
	/// returned.
	func AsCMYKString(prefix: String = "&", inclAlpha: Bool = false) -> String? {
		var colS = prefix
		
		guard let colRGB = self.usingColorSpace(NSColorSpace.genericCMYK) else { return nil }
		
		let C = Int16(colRGB.cyanComponent * 100)
		let Y = Int16(colRGB.yellowComponent * 100)
		let M = Int16(colRGB.magentaComponent * 100)
		let K = Int16(colRGB.blackComponent * 100)
		
		if C < 0 || C > 255 || Y < 0 || Y > 255 || M < 0 || M > 255 || K < 0 || K > 255 { return nil }
		
		colS += String(format: "%02X", C)
		colS += String(format: "%02X", M)
		colS += String(format: "%02X", Y)
		colS += String(format: "%02X", K)
		
		if inclAlpha {
			let A = Int16(colRGB.alphaComponent * 100)
			if A < 0 || A > 255 { return nil }
			colS += String(format: "%02X", A)
		}
		
		return colS
	}
	
	/// Assumes prefix is one of &, x or no prefix.
	/// This is checked by using the length (6/7 or 8/9 characters).
	static func FromRGB(string: String) -> NSColor? {
		let ct = string.count
		var colString = string.uppercased()
		if ct < 6 || ct > 9  { return nil }
		if ct == 7 || ct == 9 {
			colString = String(string[string.index(after: string.startIndex)...])
		}
		
		if !colString.OnlyContains(chars: "0123456789ABCDEF") { return nil }
		
		let redPart = String(colString.GetChar(N: 0)!) + String(colString.GetChar(N: 1)!)
		let greenPart = String(colString.GetChar(N: 2)!) + String(colString.GetChar(N: 3)!)
		let bluePart = String(colString.GetChar(N: 4)!) + String(colString.GetChar(N: 5)!)
		
		var alpha : CGFloat = 1
		if colString.count == 8 {
			let alphaPart = String(colString.GetChar(N: 6)!) + String(colString.GetChar(N: 7)!)
			alpha = CGFloat(Int(alphaPart)!) / 100
		}
		
		let red = CGFloat(Int(redPart)!) / 100
		let green = CGFloat(Int(greenPart)!) / 100
		let blue = CGFloat(Int(bluePart)!) / 100
		
		return NSColor(red: red, green: green, blue: blue, alpha: alpha)
	}
	
	/// Assumes prefix is one of &, x or no prefix.
	/// This is checked by using the length (8/9 or 10/11 characters).
	static func FromCMYK(string: String) -> NSColor? {
		let ct = string.count
		var colString = string.uppercased()
		if ct < 8 || ct > 11  { return nil }
		if ct == 9 || ct == 11 {
			colString = String(string[string.index(after: string.startIndex)...])
		}
		
		if !colString.OnlyContains(chars: "0123456789ABCDEF") { return nil }
		
		let cyanPart = String(colString.GetChar(N: 0)!) + String(colString.GetChar(N: 1)!)
		let magentaPart = String(colString.GetChar(N: 2)!) + String(colString.GetChar(N: 3)!)
		let yellowPart = String(colString.GetChar(N: 4)!) + String(colString.GetChar(N: 5)!)
		let blackPart = String(colString.GetChar(N: 6)!) + String(colString.GetChar(N: 7)!)
		
		var alpha : CGFloat = 1
		if colString.count == 10 {
			let alphaPart = String(colString.GetChar(N: 8)!) + String(colString.GetChar(N: 9)!)
			alpha = CGFloat(Int(alphaPart)!) / 100
		}
		
		let cyan = CGFloat(Int(cyanPart)!) / 100
		let magenta = CGFloat(Int(magentaPart)!) / 100
		let yellow = CGFloat(Int(yellowPart)!) / 100
		let black = CGFloat(Int(blackPart)!) / 100
		
		return NSColor(deviceCyan: cyan, magenta: magenta, yellow: yellow, black: black, alpha: alpha)
	}
}
