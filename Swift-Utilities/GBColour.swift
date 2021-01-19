//
//  GBColour.swift
//  MapGrid
//
//  Created by tridiak on 3/11/20.
//  Copyright © 2020 tridiak. All rights reserved.
//

#if os(OSX)
import AppKit
typealias UnvColor = NSColor
typealias GBImage = NSImage
typealias GBFont = NSFont
#elseif os(iOS)
import UIKit
typealias UnvColor = UIColor
typealias GBImage = UIImage
typealias GBFont = UIFont
#endif

/// Colour struct. Represented by 0-255 R,G,B,A.
/// Can return native colour types.
struct GBColour : Codable, Equatable, Hashable {
	private(set) var red : UInt8 = 0
	private(set) var green : UInt8 = 0
	private(set) var blue : UInt8 = 0
	private(set) var alpha : UInt8 = 255
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(self.AsUInt())
	}
	
	/// Returns red as floating point 0 - 1
	var R : CGFloat { return CGFloat(red) / 255 }
	/// Returns green as floating point 0 - 1
	var G : CGFloat { return CGFloat(green) / 255 }
	/// Returns blue as floating point 0 - 1
	var B : CGFloat { return CGFloat(blue) / 255 }
	/// Returns alpha as floating point 0 - 1
	var A : CGFloat { return CGFloat(alpha) / 255 }
	
	/// Copy constructor essentially.
	init(another:GBColour) {
		red = another.red
		green = another.green
		blue = another.blue
		alpha = another.alpha
	}
	
	/// Common constructor
	init(red R:UInt8, green G:UInt8, blue B:UInt8, alpha A:UInt8=255) {
		red = R; green = G; blue = B; alpha = A;
	}
	
	/// Convert a formatted string to a colour. Will return nil if string format is invalid.
	///
	/// - Parameter from:  colour string in form of '&RRGGBBAA' or '&RRGGBB'
	init?(from:String) {
		let inclAlpha = from.count == 9
		if from.count != 7 && from.count != 9 { return nil }
		if from.first! != "&" { return nil }
		
		let colour = String( from[from.index(after: from.startIndex)...] )
		
		guard var V = UInt32(colour, radix:16) else { return nil }
		// Need to do this otherwise red value will be b16-23, not 24-31
		if !inclAlpha { V = V << 8 }
		
		red = UInt8((V >> 24) & 0xFF)
		green = UInt8( (V >> 16) & 0xFF)
		blue = UInt8 ( (V >> 8) & 0xFF)
		alpha = inclAlpha ? UInt8 ( V & 0xFF) : 255
		
	}
	
	/// Initialise passing native colour. Will convert colour to RGB colour space.
	/// Will return nil if colour space conversion is not possible.
	init?(colour: UnvColor) {
		// this conversion will not work with iOS
		#if os(OSX)
		var col : UnvColor!
		
		if #available(macOS 10.14, *) {
			guard let c = colour.usingColorSpace(NSColorSpace.deviceRGB) else { return nil }
			col = c
		}
		else {
			guard let c = colour.usingColorSpaceName(NSColorSpaceName.deviceRGB) else {return nil}
			col = c
		}
		
		
		#elseif os(iOS)
		guard let col = colour.ConverTo(colourSpace: CGColorSpace.init(name: CGColorSpace.sRGB)!) else {return nil}
		#endif
		// Important : iOS version uses an extension for XXXcompnent property as it is only defined in MacOS.
		red = UInt8(col.redComponent * 255)
		green = UInt8(col.greenComponent * 255)
		blue = UInt8(col.blueComponent * 255)
		alpha = UInt8(col.alphaComponent * 255)
	}
	
	/// Convert colour to hex string.
	///
	/// - Returns: Colour returned as '&RRGGBBAA' in hexidecimal format
	func ToHexString() -> String {
		return String(format:"&%02X%02X%02X%02X", red, green, blue, alpha)
	}
	
	/// - Returns: Colour as 'RRGGBB'
	func ToShortHexString() -> String {
		return String(format:"&%02X%02X%02X", red, green, blue)
	}
	
	/// Returns the component values as an UInt32
	/// Red: 11, Green : 44, Blue : 99, Alpha : FF -> (Hi)FF994411(Lo)
	func AsUInt() -> UInt32 {
		return UInt32(red) + (UInt32(green) << 8) + (UInt32(blue) << 16) + (UInt32(alpha) << 24)
	}
	
	/// Returns colour os 0-1 floating point as a tuple.
	func AsFP() -> (R:CGFloat, G:CGFloat, B:CGFloat, A:CGFloat) {
		return (self.R, self.G, self.B, self.A)
	}
	
	/// Returns colour as [Red,Green,Blue,Alpha] array
	func AsDPArray() -> [CGFloat] {
		return [R, G, B, A]
	}
	
	/// Returns as native colour type (NSColor or UIColor)
	func ToColourType() -> UnvColor {
		let FP = AsFP()
		return UnvColor.init(red: FP.R, green: FP.G, blue: FP.B, alpha: FP.A )
	}
	
	//------------------------
	// MARK:-
	
	static func == (LHS: GBColour, RHS: GBColour) -> Bool {
		return LHS.red == RHS.red && LHS.green == RHS.green && LHS.blue == RHS.blue && LHS.alpha == RHS.alpha
	}
	
	static func != (LHS: GBColour, RHS: GBColour) -> Bool {
		return !(LHS == RHS)
	}
	
	//------------------------
	// MARK:-
	
	static let black = GBColour(colour: .black)!
	static let blue = GBColour(colour: .blue)!
	static let brown = GBColour(colour: .brown)!
	static let gray = GBColour(colour: .gray)!
	static let green = GBColour(colour: .green)!
	static let orange = GBColour(colour: .orange)!
	static let pink = GBColour(colour: UnvColor(deviceRed: 1, green: 105.0 / 255.0, blue: 180.0 / 255.0, alpha: 1))!
	static let purple = GBColour(colour: .purple)!
	static let red = GBColour(colour: .red)!
	static let yellow = GBColour(colour: .yellow)!
	static let white = GBColour(colour: .white)!
	
	static let aliceBlue = 	GBColour(colour: UnvColor(deviceRed: 240.0 / 255.0, green: 248.0 / 255.0, blue: 1, alpha: 1))!
	static let antiqueWhite = 	GBColour(colour: UnvColor(deviceRed: 250.0 / 255.0, green: 235.0 / 255.0, blue: 215.0 / 255.0, alpha: 1))!
	// Same as cyan
	//static let aqua = 	GBColour(colour: UnvColor(deviceRed: 0, green: 1, blue: 1, alpha: 1))!
	static let aquaMarine = 	GBColour(colour: UnvColor(deviceRed: 127.0 / 255.0, green: 1, blue: 212.0 / 255.0, alpha: 1))!
	static let azure = 	GBColour(colour: UnvColor(deviceRed: 240.0 / 255.0, green: 1, blue: 1, alpha: 1))!
	static let beige = 	GBColour(colour: UnvColor(deviceRed: 245.0 / 255.0, green: 245.0 / 255.0, blue: 220.0 / 255.0, alpha: 1))!
	static let bisque = 	GBColour(colour: UnvColor(deviceRed: 1, green: 228.0 / 255.0, blue: 196.0 / 255.0, alpha: 1))!
	static let blanchedAlmond = 	GBColour(colour: UnvColor(deviceRed: 1, green: 235.0 / 255.0, blue: 205.0 / 255.0, alpha: 1))!
	static let blueViolet = 	GBColour(colour: UnvColor(deviceRed: 138.0 / 255.0, green: 43.0 / 255.0, blue: 226.0 / 255.0, alpha: 1))!
	static let burlyWood = 	GBColour(colour: UnvColor(deviceRed: 222.0 / 255.0, green: 184.0 / 255.0, blue: 135.0 / 255.0, alpha: 1))!
	static let cadetBlue = 	GBColour(colour: UnvColor(deviceRed: 95.0 / 255.0, green: 158.0 / 255.0, blue: 160.0 / 255.0, alpha: 1))!
	static let chartReuse = 	GBColour(colour: UnvColor(deviceRed: 127.0 / 255.0, green: 1, blue: 0.0 / 255.0, alpha: 1))!
	static let chocolate = 	GBColour(colour: UnvColor(deviceRed: 210.0 / 255.0, green: 105.0 / 255.0, blue: 30.0 / 255.0, alpha: 1))!
	static let coral = 	GBColour(colour: UnvColor(deviceRed: 1, green: 127.0 / 255.0, blue: 80.0 / 255.0, alpha: 1))!
	static let cornFlowerBlue = 	GBColour(colour: UnvColor(deviceRed: 100.0 / 255.0, green: 149.0 / 255.0, blue: 237.0 / 255.0, alpha: 1))!
	static let cornSilk = 	GBColour(colour: UnvColor(deviceRed: 1, green: 248.0 / 255.0, blue: 220.0 / 255.0, alpha: 1))!
	static let crimson = 	GBColour(colour: UnvColor(deviceRed: 220.0 / 255.0, green: 20.0 / 255.0, blue: 60.0 / 255.0, alpha: 1))!
	static let cyan = 	GBColour(colour: UnvColor(deviceRed: 0.0 / 255.0, green: 1, blue: 1, alpha: 1))!
	static let darkBlue = 	GBColour(colour: UnvColor(deviceRed: 0.0 / 255.0, green: 0.0 / 255.0, blue: 139.0 / 255.0, alpha: 1))!
	static let darkCyan = 	GBColour(colour: UnvColor(deviceRed: 0.0 / 255.0, green: 139.0 / 255.0, blue: 139.0 / 255.0, alpha: 1))!
	static let darkGoldenRod = 	GBColour(colour: UnvColor(deviceRed: 184.0 / 255.0, green: 134.0 / 255.0, blue: 11.0 / 255.0, alpha: 1))!
	static let darkGray = 	GBColour(colour: UnvColor(deviceRed: 169.0 / 255.0, green: 169.0 / 255.0, blue: 169.0 / 255.0, alpha: 1))!
	static let darkGreen = 	GBColour(colour: UnvColor(deviceRed: 0.0 / 255.0, green: 100.0 / 255.0, blue: 0.0 / 255.0, alpha: 1))!
	static let darkKhaki = 	GBColour(colour: UnvColor(deviceRed: 189.0 / 255.0, green: 183.0 / 255.0, blue: 107.0 / 255.0, alpha: 1))!
	static let darkMagenta = 	GBColour(colour: UnvColor(deviceRed: 139.0 / 255.0, green: 0.0 / 255.0, blue: 139.0 / 255.0, alpha: 1))!
	static let darkOliveGreen = 	GBColour(colour: UnvColor(deviceRed: 85.0 / 255.0, green: 107.0 / 255.0, blue: 47.0 / 255.0, alpha: 1))!
	static let darkOrange = 	GBColour(colour: UnvColor(deviceRed: 1, green: 140.0 / 255.0, blue: 0.0 / 255.0, alpha: 1))!
	static let darkOrchid = 	GBColour(colour: UnvColor(deviceRed: 153.0 / 255.0, green: 50.0 / 255.0, blue: 204.0 / 255.0, alpha: 1))!
	static let darkRed = 	GBColour(colour: UnvColor(deviceRed: 139.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1))!
	static let darkSalmon = 	GBColour(colour: UnvColor(deviceRed: 233.0 / 255.0, green: 150.0 / 255.0, blue: 122.0 / 255.0, alpha: 1))!
	static let darkSeaGreen = 	GBColour(colour: UnvColor(deviceRed: 143.0 / 255.0, green: 188.0 / 255.0, blue: 143.0 / 255.0, alpha: 1))!
	static let darkSlateBlue = 	GBColour(colour: UnvColor(deviceRed: 72.0 / 255.0, green: 61.0 / 255.0, blue: 139.0 / 255.0, alpha: 1))!
	static let darkSlateGray = 	GBColour(colour: UnvColor(deviceRed: 47.0 / 255.0, green: 79.0 / 255.0, blue: 79.0 / 255.0, alpha: 1))!
	static let darkTurquoise = 	GBColour(colour: UnvColor(deviceRed: 0.0 / 255.0, green: 206.0 / 255.0, blue: 209.0 / 255.0, alpha: 1))!
	static let darkViolet = 	GBColour(colour: UnvColor(deviceRed: 148.0 / 255.0, green: 0.0 / 255.0, blue: 211.0 / 255.0, alpha: 1))!
	static let deepPink = 	GBColour(colour: UnvColor(deviceRed: 1, green: 20.0 / 255.0, blue: 147.0 / 255.0, alpha: 1))!
	static let deepSkyBlue = 	GBColour(colour: UnvColor(deviceRed: 0.0 / 255.0, green: 191.0 / 255.0, blue: 1, alpha: 1))!
	static let dimGray = 	GBColour(colour: UnvColor(deviceRed: 105.0 / 255.0, green: 105.0 / 255.0, blue: 105.0 / 255.0, alpha: 1))!
	static let dodgerBlue = 	GBColour(colour: UnvColor(deviceRed: 30.0 / 255.0, green: 144.0 / 255.0, blue: 1, alpha: 1))!
	static let firebrick = 	GBColour(colour: UnvColor(deviceRed: 178.0 / 255.0, green: 34.0 / 255.0, blue: 34.0 / 255.0, alpha: 1))!
	static let floralWhite = 	GBColour(colour: UnvColor(deviceRed: 1, green: 250.0 / 255.0, blue: 240.0 / 255.0, alpha: 1))!
	static let forestGreen = 	GBColour(colour: UnvColor(deviceRed: 34.0 / 255.0, green: 139.0 / 255.0, blue: 34.0 / 255.0, alpha: 1))!
	static let gainsboro = 	GBColour(colour: UnvColor(deviceRed: 220.0 / 255.0, green: 220.0 / 255.0, blue: 220.0 / 255.0, alpha: 1))!
	static let ghostWhite = 	GBColour(colour: UnvColor(deviceRed: 248.0 / 255.0, green: 248.0 / 255.0, blue: 1, alpha: 1))!
	static let gold = 	GBColour(colour: UnvColor(deviceRed: 1, green: 215.0 / 255.0, blue: 0.0 / 255.0, alpha: 1))!
	static let goldenRod = 	GBColour(colour: UnvColor(deviceRed: 218.0 / 255.0, green: 165.0 / 255.0, blue: 32.0 / 255.0, alpha: 1))!
	static let greenYellow = 	GBColour(colour: UnvColor(deviceRed: 173.0 / 255.0, green: 1, blue: 47.0 / 255.0, alpha: 1))!
	static let honeydew = 	GBColour(colour: UnvColor(deviceRed: 240.0 / 255.0, green: 1, blue: 240.0 / 255.0, alpha: 1))!
	// Same as Pink
//	static let hotPink = 	GBColour(colour: UnvColor(deviceRed: 1, green: 105.0 / 255.0, blue: 180.0 / 255.0, alpha: 1))!
	static let indianRed = 	GBColour(colour: UnvColor(deviceRed: 205.0 / 255.0, green: 92.0 / 255.0, blue: 92.0 / 255.0, alpha: 1))!
	static let indigo = 	GBColour(colour: UnvColor(deviceRed: 75.0 / 255.0, green: 0.0 / 255.0, blue: 130.0 / 255.0, alpha: 1))!
	static let ivory = 	GBColour(colour: UnvColor(deviceRed: 1, green: 1, blue: 240.0 / 255.0, alpha: 1))!
	static let khaki = 	GBColour(colour: UnvColor(deviceRed: 240.0 / 255.0, green: 230.0 / 255.0, blue: 140.0 / 255.0, alpha: 1))!
	static let lavender = 	GBColour(colour: UnvColor(deviceRed: 230.0 / 255.0, green: 230.0 / 255.0, blue: 250.0 / 255.0, alpha: 1))!
	static let lavenderBlush = 	GBColour(colour: UnvColor(deviceRed: 1, green: 240.0 / 255.0, blue: 245.0 / 255.0, alpha: 1))!
	static let lawnGreen = 	GBColour(colour: UnvColor(deviceRed: 124.0 / 255.0, green: 252.0 / 255.0, blue: 0.0 / 255.0, alpha: 1))!
	static let lemonChiffon = 	GBColour(colour: UnvColor(deviceRed: 1, green: 250.0 / 255.0, blue: 205.0 / 255.0, alpha: 1))!
	static let lightBlue = 	GBColour(colour: UnvColor(deviceRed: 173.0 / 255.0, green: 216.0 / 255.0, blue: 230.0 / 255.0, alpha: 1))!
	static let lightCoral = 	GBColour(colour: UnvColor(deviceRed: 240.0 / 255.0, green: 128.0 / 255.0, blue: 128.0 / 255.0, alpha: 1))!
	static let lightCyan = 	GBColour(colour: UnvColor(deviceRed: 224.0 / 255.0, green: 1, blue: 1, alpha: 1))!
	static let lightGoldenRodYellow = 	GBColour(colour: UnvColor(deviceRed: 250.0 / 255.0, green: 250.0 / 255.0, blue: 210.0 / 255.0, alpha: 1))!
	static let lightGray = 	GBColour(colour: UnvColor(deviceRed: 211.0 / 255.0, green: 211.0 / 255.0, blue: 211.0 / 255.0, alpha: 1))!
	static let lightGreen = 	GBColour(colour: UnvColor(deviceRed: 144.0 / 255.0, green: 238.0 / 255.0, blue: 144.0 / 255.0, alpha: 1))!
	static let lightPink = 	GBColour(colour: UnvColor(deviceRed: 1, green: 182.0 / 255.0, blue: 193.0 / 255.0, alpha: 1))!
	static let lightSalmon = 	GBColour(colour: UnvColor(deviceRed: 1, green: 160.0 / 255.0, blue: 122.0 / 255.0, alpha: 1))!
	static let lightSeaGreen = 	GBColour(colour: UnvColor(deviceRed: 32.0 / 255.0, green: 178.0 / 255.0, blue: 170.0 / 255.0, alpha: 1))!
	static let lightSkyBlue = 	GBColour(colour: UnvColor(deviceRed: 135.0 / 255.0, green: 206.0 / 255.0, blue: 250.0 / 255.0, alpha: 1))!
	static let lightSlateGray = 	GBColour(colour: UnvColor(deviceRed: 119.0 / 255.0, green: 136.0 / 255.0, blue: 153.0 / 255.0, alpha: 1))!
	static let lightSteelBlue = 	GBColour(colour: UnvColor(deviceRed: 176.0 / 255.0, green: 196.0 / 255.0, blue: 222.0 / 255.0, alpha: 1))!
	static let lightYellow = 	GBColour(colour: UnvColor(deviceRed: 1, green: 1, blue: 224.0 / 255.0, alpha: 1))!
	// Same as Green
//	static let lime = 	GBColour(colour: UnvColor(deviceRed: 0.0 / 255.0, green: 1, blue: 0.0 / 255.0, alpha: 1))!
	static let limeGreen = 	GBColour(colour: UnvColor(deviceRed: 50.0 / 255.0, green: 205.0 / 255.0, blue: 50.0 / 255.0, alpha: 1))!
	static let linen = 	GBColour(colour: UnvColor(deviceRed: 250.0 / 255.0, green: 240.0 / 255.0, blue: 230.0 / 255.0, alpha: 1))!
	static let magenta = 	GBColour(colour: UnvColor(deviceRed: 1, green: 0.0 / 255.0, blue: 1, alpha: 1))!
	static let maroon = 	GBColour(colour: UnvColor(deviceRed: 128.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1))!
	static let mediumAquaMarine = 	GBColour(colour: UnvColor(deviceRed: 102.0 / 255.0, green: 205.0 / 255.0, blue: 170.0 / 255.0, alpha: 1))!
	static let mediumBlue = 	GBColour(colour: UnvColor(deviceRed: 0.0 / 255.0, green: 0.0 / 255.0, blue: 205.0 / 255.0, alpha: 1))!
	static let mediumOrchid = 	GBColour(colour: UnvColor(deviceRed: 186.0 / 255.0, green: 85.0 / 255.0, blue: 211.0 / 255.0, alpha: 1))!
	static let mediumPurple = 	GBColour(colour: UnvColor(deviceRed: 147.0 / 255.0, green: 112.0 / 255.0, blue: 219.0 / 255.0, alpha: 1))!
	static let mediumSeaGreen = 	GBColour(colour: UnvColor(deviceRed: 60.0 / 255.0, green: 179.0 / 255.0, blue: 113.0 / 255.0, alpha: 1))!
	static let mediumSlateBlue = 	GBColour(colour: UnvColor(deviceRed: 123.0 / 255.0, green: 104.0 / 255.0, blue: 238.0 / 255.0, alpha: 1))!
	static let mediumSpringGreen = 	GBColour(colour: UnvColor(deviceRed: 0.0 / 255.0, green: 250.0 / 255.0, blue: 154.0 / 255.0, alpha: 1))!
	static let mediumTurquoise = 	GBColour(colour: UnvColor(deviceRed: 72.0 / 255.0, green: 209.0 / 255.0, blue: 204.0 / 255.0, alpha: 1))!
	static let mediumVioletRed = 	GBColour(colour: UnvColor(deviceRed: 199.0 / 255.0, green: 21.0 / 255.0, blue: 133.0 / 255.0, alpha: 1))!
	static let midnightBlue = 	GBColour(colour: UnvColor(deviceRed: 25.0 / 255.0, green: 25.0 / 255.0, blue: 112.0 / 255.0, alpha: 1))!
	static let mintCream = 	GBColour(colour: UnvColor(deviceRed: 245.0 / 255.0, green: 1, blue: 250.0 / 255.0, alpha: 1))!
	static let mistyRose = 	GBColour(colour: UnvColor(deviceRed: 1, green: 228.0 / 255.0, blue: 225.0 / 255.0, alpha: 1))!
	static let moccasin = 	GBColour(colour: UnvColor(deviceRed: 1, green: 228.0 / 255.0, blue: 181.0 / 255.0, alpha: 1))!
	static let navajoWhite = 	GBColour(colour: UnvColor(deviceRed: 1, green: 222.0 / 255.0, blue: 173.0 / 255.0, alpha: 1))!
	static let navy = 	GBColour(colour: UnvColor(deviceRed: 0.0 / 255.0, green: 0.0 / 255.0, blue: 128.0 / 255.0, alpha: 1))!
	static let oldLace = 	GBColour(colour: UnvColor(deviceRed: 253.0 / 255.0, green: 245.0 / 255.0, blue: 230.0 / 255.0, alpha: 1))!
	static let olive = 	GBColour(colour: UnvColor(deviceRed: 128.0 / 255.0, green: 128.0 / 255.0, blue: 0.0 / 255.0, alpha: 1))!
	static let oliveDrab = 	GBColour(colour: UnvColor(deviceRed: 107.0 / 255.0, green: 142.0 / 255.0, blue: 35.0 / 255.0, alpha: 1))!
	static let orangeRed = 	GBColour(colour: UnvColor(deviceRed: 1, green: 69.0 / 255.0, blue: 0.0 / 255.0, alpha: 1))!
	static let orchid = 	GBColour(colour: UnvColor(deviceRed: 218.0 / 255.0, green: 112.0 / 255.0, blue: 214.0 / 255.0, alpha: 1))!
	static let paleGoldenRod = 	GBColour(colour: UnvColor(deviceRed: 238.0 / 255.0, green: 232.0 / 255.0, blue: 170.0 / 255.0, alpha: 1))!
	static let paleGreen = 	GBColour(colour: UnvColor(deviceRed: 152.0 / 255.0, green: 251.0 / 255.0, blue: 152.0 / 255.0, alpha: 1))!
	static let paleTurquoise = 	GBColour(colour: UnvColor(deviceRed: 175.0 / 255.0, green: 238.0 / 255.0, blue: 238.0 / 255.0, alpha: 1))!
	static let paleVioletRed = 	GBColour(colour: UnvColor(deviceRed: 219.0 / 255.0, green: 112.0 / 255.0, blue: 147.0 / 255.0, alpha: 1))!
	static let papayaWhip = 	GBColour(colour: UnvColor(deviceRed: 1, green: 239.0 / 255.0, blue: 213.0 / 255.0, alpha: 1))!
	static let peachPuff = 	GBColour(colour: UnvColor(deviceRed: 1, green: 218.0 / 255.0, blue: 185.0 / 255.0, alpha: 1))!
	static let peru = 	GBColour(colour: UnvColor(deviceRed: 205.0 / 255.0, green: 133.0 / 255.0, blue: 63.0 / 255.0, alpha: 1))!
	static let plum = 	GBColour(colour: UnvColor(deviceRed: 221.0 / 255.0, green: 160.0 / 255.0, blue: 221.0 / 255.0, alpha: 1))!
	static let powderBlue = 	GBColour(colour: UnvColor(deviceRed: 176.0 / 255.0, green: 224.0 / 255.0, blue: 230.0 / 255.0, alpha: 1))!
	static let rosyBrown = 	GBColour(colour: UnvColor(deviceRed: 188.0 / 255.0, green: 143.0 / 255.0, blue: 143.0 / 255.0, alpha: 1))!
	static let royalBlue = 	GBColour(colour: UnvColor(deviceRed: 65.0 / 255.0, green: 105.0 / 255.0, blue: 225.0 / 255.0, alpha: 1))!
	static let saddleBrown = 	GBColour(colour: UnvColor(deviceRed: 139.0 / 255.0, green: 69.0 / 255.0, blue: 19.0 / 255.0, alpha: 1))!
	static let salmon = 	GBColour(colour: UnvColor(deviceRed: 250.0 / 255.0, green: 128.0 / 255.0, blue: 114.0 / 255.0, alpha: 1))!
	static let sandyBrown = 	GBColour(colour: UnvColor(deviceRed: 244.0 / 255.0, green: 164.0 / 255.0, blue: 96.0 / 255.0, alpha: 1))!
	static let seaGreen = 	GBColour(colour: UnvColor(deviceRed: 46.0 / 255.0, green: 139.0 / 255.0, blue: 87.0 / 255.0, alpha: 1))!
	static let seaShell = 	GBColour(colour: UnvColor(deviceRed: 1, green: 245.0 / 255.0, blue: 238.0 / 255.0, alpha: 1))!
	static let sienna = 	GBColour(colour: UnvColor(deviceRed: 160.0 / 255.0, green: 82.0 / 255.0, blue: 45.0 / 255.0, alpha: 1))!
	static let silver = 	GBColour(colour: UnvColor(deviceRed: 192.0 / 255.0, green: 192.0 / 255.0, blue: 192.0 / 255.0, alpha: 1))!
	static let skyBlue = 	GBColour(colour: UnvColor(deviceRed: 135.0 / 255.0, green: 206.0 / 255.0, blue: 235.0 / 255.0, alpha: 1))!
	static let slateBlue = 	GBColour(colour: UnvColor(deviceRed: 106.0 / 255.0, green: 90.0 / 255.0, blue: 205.0 / 255.0, alpha: 1))!
	static let slateGray = 	GBColour(colour: UnvColor(deviceRed: 112.0 / 255.0, green: 128.0 / 255.0, blue: 144.0 / 255.0, alpha: 1))!
	static let snow = 	GBColour(colour: UnvColor(deviceRed: 1, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1))!
	static let springGreen = 	GBColour(colour: UnvColor(deviceRed: 0.0 / 255.0, green: 1, blue: 127.0 / 255.0, alpha: 1))!
	static let steelBlue = 	GBColour(colour: UnvColor(deviceRed: 70.0 / 255.0, green: 130.0 / 255.0, blue: 180.0 / 255.0, alpha: 1))!
	static let tan = 	GBColour(colour: UnvColor(deviceRed: 210.0 / 255.0, green: 180.0 / 255.0, blue: 140.0 / 255.0, alpha: 1))!
	static let teal = 	GBColour(colour: UnvColor(deviceRed: 0.0 / 255.0, green: 128.0 / 255.0, blue: 128.0 / 255.0, alpha: 1))!
	static let thistle = 	GBColour(colour: UnvColor(deviceRed: 216.0 / 255.0, green: 191.0 / 255.0, blue: 216.0 / 255.0, alpha: 1))!
	static let tomato = 	GBColour(colour: UnvColor(deviceRed: 1, green: 99.0 / 255.0, blue: 71.0 / 255.0, alpha: 1))!
	static let turquoise = 	GBColour(colour: UnvColor(deviceRed: 64.0 / 255.0, green: 224.0 / 255.0, blue: 208.0 / 255.0, alpha: 1))!
	static let violet = 	GBColour(colour: UnvColor(deviceRed: 238.0 / 255.0, green: 130.0 / 255.0, blue: 238.0 / 255.0, alpha: 1))!
	static let wheat = 	GBColour(colour: UnvColor(deviceRed: 245.0 / 255.0, green: 222.0 / 255.0, blue: 179.0 / 255.0, alpha: 1))!
	static let whiteSmoke = 	GBColour(colour: UnvColor(deviceRed: 245.0 / 255.0, green: 245.0 / 255.0, blue: 245.0 / 255.0, alpha: 1))!
	static let yellowGreen = 	GBColour(colour: UnvColor(deviceRed: 154.0 / 255.0, green: 205.0 / 255.0, blue: 50.0 / 255.0, alpha: 1))!

	
	static let constColours = [GBColour.black, .blue, .white, .brown, .gray, .green, .orange, .pink, .purple, .red, .yellow,
	   aliceBlue, antiqueWhite, /*aqua,*/ aquaMarine, azure, beige, bisque, blanchedAlmond, blueViolet, burlyWood, cadetBlue,
	   chartReuse, chocolate, coral, cornFlowerBlue, cornSilk, crimson, cyan, darkBlue, darkCyan, darkGoldenRod, darkGray,
	   darkGreen, darkKhaki, darkMagenta, darkOliveGreen, darkOrange, darkOrchid, darkRed, darkSalmon, darkSeaGreen,
	   darkSlateBlue, darkSlateGray, darkTurquoise, darkViolet, deepPink, deepSkyBlue, dimGray, dodgerBlue, firebrick,
	   floralWhite, forestGreen, gainsboro, ghostWhite, gold, goldenRod, greenYellow, honeydew, /*hotPink,*/ indianRed,
	   indigo, ivory, khaki, lavender, lavenderBlush, lawnGreen, lemonChiffon, lightBlue, lightCoral, lightCyan,
	   lightGoldenRodYellow, lightGray, lightGreen, lightPink, lightSalmon, lightSeaGreen, lightSkyBlue, lightSlateGray,
	   lightSteelBlue, lightYellow, /*lime,*/ limeGreen, linen, magenta, maroon, mediumAquaMarine, mediumBlue, mediumOrchid,
	   mediumPurple, mediumSeaGreen, mediumSlateBlue, mediumSpringGreen, mediumTurquoise, mediumVioletRed, midnightBlue,
	   mintCream, mistyRose, moccasin, navajoWhite, navy, oldLace, olive, oliveDrab, orangeRed, orchid, paleGoldenRod,
	   paleGreen, paleTurquoise, paleVioletRed, papayaWhip, peachPuff, peru, plum, powderBlue, rosyBrown, royalBlue,
	   saddleBrown, salmon, sandyBrown, seaGreen, seaShell, sienna, silver, skyBlue, slateBlue, slateGray, snow,
	   springGreen, steelBlue, tan, teal, thistle, tomato, turquoise, violet, wheat, whiteSmoke, yellowGreen,
	]
	
	
}

