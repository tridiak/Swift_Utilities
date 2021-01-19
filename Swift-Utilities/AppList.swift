//
//  AppList.swift
//  Links
//
//  Created by tridiak on 11/09/19.
//  Copyright © 2019 tridiak. All rights reserved.
//

import Cocoa

/*
Get a list of apps which can open passed URL.
Or get default app for passed url.

Get app icon.

*/

//*********** To be tested

struct AppInfo : Codable, Hashable {
	let path : String
	let icon : NSImage
	var appName : String {
		get {
			return FileManager.default.displayName(atPath: path)
		}
	}
	
	var version : String {
		get {
			guard let bundle = Bundle.init(path: path) else { return "v ?" }
			guard let D = bundle.infoDictionary else { return "v ?" }
			return (D["CFBundleShortVersionString"] as? String) ?? "v ?"
		}
	}
	
	// MARK: Codable
	
	enum CodingKeys: String, CodingKey {
		case path
	}
	
	init(path P: String, icon I: NSImage) {
		path = P
		icon = I
	}
	
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		path = try values.decode(String.self, forKey: .path)
		icon = NSWorkspace.shared.icon(forFile: path)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(path, forKey: .path)
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(appName)
	}
}

//----

func AllAppsFor(url: URL) -> [AppInfo]? {
	guard let apps = LSCopyApplicationURLsForURL(NSURL(string: url.absoluteString)!, [LSRolesMask.editor, .viewer]) else { return nil }
	let cfArray = apps.takeUnretainedValue() as CFArray
	
	var appInfo : [AppInfo] = []
	for idx in 0..<CFArrayGetCount(cfArray) {
		let u = UnsafeRawPointer(CFArrayGetValueAtIndex(cfArray, idx))!// as! CFURL
		let z = unsafeBitCast(u, to: CFURL.self)
		let p = CFURLCopyFileSystemPath(z, CFURLPathStyle.cfurlposixPathStyle)! as NSString as String
		let i = NSWorkspace.shared.icon(forFile: p)
		
		appInfo.append(AppInfo(path: p, icon: i))
	}
	
	appInfo = Array(Set(appInfo)).sorted(by: { (A1, A2) -> Bool in
		return A1.appName < A2.appName
	})
	
	return appInfo
}

func DefaultAppFor(url: URL) -> AppInfo? {
	guard let app = LSCopyDefaultApplicationURLForURL(NSURL(string: url.absoluteString)!, LSRolesMask.viewer, nil) else { return nil }
	let u = app.takeUnretainedValue()
	let p = CFURLCopyFileSystemPath(u, CFURLPathStyle.cfurlposixPathStyle)! as NSString as String
	let i = NSWorkspace.shared.icon(forFile: p)
	
	return AppInfo(path: p, icon: i)
}
