//
//  ABinaryFile.swift
//  Swift-Utilities
//
//  Created by tridiak on 9/12/18.
//  Copyright © 2018 tridiak. All rights reserved.
//

import Foundation


/*
ABinaryFile either loads the entire file in or it doesn't.
If it can't, the initialiser will return nil.
The class is read only.
*/

enum ABinaryFileEx : Error {
	case fileAccessEx
	case notAFileEx
	case cannotOpenFile
	case fileLoadFail
	case rangeEx
}

class ABinaryFile {
	// The file data.
	private var blob : UnsafeMutableRawPointer!
	// Above blob as a UInt8 array.
	private(set) var bytePtr : UnsafePointer<UInt8>!
	private(set) var dataSize : UInt64 = 0
	
	/// Load file using a file descriptor
	init?(descriptor: Int32) {
		var st = stat()
		var res = fstat(descriptor, &st)
		if res != 0 { return nil }
		
		if (st.st_mode & S_IFMT) != S_IFREG { return nil }
		
		var F : UnsafeMutablePointer<FILE>!
		F = fdopen(descriptor, "r")
		
		if F == nil { return nil }
		
		defer {
    		fclose(F)
		}
		
		blob = UnsafeMutableRawPointer.allocate(byteCount: Int(st.st_size), alignment: 1)
		if blob == nil { return nil }
		
		dataSize = UInt64(st.st_size)
		let itemsRead = fread(blob, Int(dataSize), 1, F)
		
		if itemsRead == 0 {
			blob.deallocate()
			return nil
		}
		
		bytePtr = UnsafePointer(blob!.bindMemory(to: UInt8.self, capacity: Int(dataSize)))
	}
	
	/// Load a file using a path
	init?(path : String) {
		var st = stat()
		var res = stat(path, &st)
		if res != 0 { return nil }
		
		if (st.st_mode & S_IFMT) != S_IFREG { return nil }
		
		var F : UnsafeMutablePointer<FILE>!
		F = fopen(path, "r")
		
		if F == nil { return nil }
		
		defer {
    		fclose(F)
		}
		
		blob = UnsafeMutableRawPointer.allocate(byteCount: Int(st.st_size), alignment: 1)
		if blob == nil { return nil }
		
		dataSize = UInt64(st.st_size)
		let itemsRead = fread(blob, Int(dataSize), 1, F)
		
		if itemsRead == 0 {
			blob.deallocate()
			return nil
		}
		
		bytePtr = UnsafePointer(blob!.bindMemory(to: UInt8.self, capacity: Int(dataSize)))
	}
	
	
	deinit {
		if blob != nil { blob.deallocate() }
	}
	
	// Subscript operator
	subscript(byte: UInt64) -> UInt8? {
		if byte >= dataSize { return nil }
		return bytePtr[Int(byte)]
	}
	
	/// Gets a UInt16 value at BYTE position.
	/// It does not factor in endianness.
	func B16(bytePos: UInt64) -> UInt16? {
		if bytePos + 2 >= dataSize { return nil }
		
		let data : UInt16 = UInt16( bytePtr[Int(bytePos)] ) << 8 + UInt16( bytePtr[Int(bytePos) + 1] )
		
		return data
	}
	
	/// Gets a UInt32 value at BYTE position.
	/// It does not factor in endianness.
	func B32(bytePos: UInt64) -> UInt32? {
		if bytePos + 4 >= dataSize { return nil }
		
		let data : UInt32 = UInt32( bytePtr[Int(bytePos)] ) << 24 + UInt32( bytePtr[Int(bytePos) + 1] ) << 16
			+ UInt32( bytePtr[Int(bytePos) + 2] ) << 8 + UInt32( bytePtr[Int(bytePos) + 3] )
		
		return data
	}
	
	/// Gets a UInt64 value at BYTE position.
	/// It does not factor in endianness.
	func B64(bytePos: UInt64) -> UInt64? {
		if bytePos + 8 >= dataSize { return nil }
		
		var data : UInt64 = UInt64( bytePtr[Int(bytePos)] ) << 56 + UInt64( bytePtr[Int(bytePos) + 1] ) << 48
		data += UInt64( bytePtr[Int(bytePos) + 2] ) << 40 + UInt64( bytePtr[Int(bytePos) + 3] ) << 32
		data += UInt64( bytePtr[Int(bytePos) + 4] ) << 24 + UInt64( bytePtr[Int(bytePos) + 5] ) << 16
		data += UInt64( bytePtr[Int(bytePos) + 6] ) << 8 + UInt64( bytePtr[Int(bytePos) + 7] )
		
		return data
	}
}

//-----------------------------------------------------------------------------
// MARK:- A Big Binary File

/*
Represents a chunk of the referenced file.
Can be accessed using subscript.
*/
struct MemoryBlob {
	private var blob : Data
	private var lumpSize : UInt16
	
	init(lump: UInt16) {
		lumpSize = lump
		blob = Data.init()
	}
	
	init(bytePtr : UnsafePointer<UInt8>, index: UInt64, size : UInt16) {
		lumpSize = size
		blob = Data.init(count: Int(lumpSize))
		for idx in index..<index+UInt64(size) {
			blob.append( bytePtr[Int(idx)] )
		}
	}
	
	init(other: MemoryBlob) {
		lumpSize = other.lumpSize
		// Check that it is a duplicate
		blob = other.blob
	}
	
	// Copy lumpSize bytes from bytePtr[index]
	fileprivate mutating func SetData(bytePtr : UnsafePointer<UInt8>, index: UInt64) {
		for idx in index..<index+UInt64(lumpSize) {
			blob[Int(idx)] = bytePtr[Int(idx)]
		}
	}
	
	fileprivate mutating func SetData(ptr: UnsafeMutableRawPointer, count: UInt16) {
		blob = Data.init(bytes: ptr, count: Int(count))
		// (buffer: p, count:Int(count))
	}
	
	fileprivate mutating func Zero() {
		for idx in 0..<lumpSize {
			blob[Int(idx)] = 0
		}
		
	}
	
	subscript(idx : UInt16) -> UInt8? {
		if idx >= lumpSize { return nil }
		return blob[Int(idx)]
	}
	
	fileprivate func Get(NBytes : UInt16, from : UInt16) throws -> [UInt8] {
		if from + NBytes > lumpSize { throw ABinaryFileEx.rangeEx }
		let ary : [UInt8] = Array(blob[from..<from + NBytes])
		
		return ary
	}
	
	func AsArray() -> [UInt8] {
		return Array(blob)
	}
}

//----------------------
// MARK:-

/*
 Class to access very big files.
 The class loads a maximum of N blocks which each are of size blockSize.
 The blockSize range is 256 - 65535.
 Max block count range is 1 to UINT_MAX, though a small number is detrimental to performance.
 A very large number will result in the system throwing a fit.

 Accessed blocks are loaded into blockArray (cache) as needed.

 The file is opened during construction, if it fails and exception will be thrown.

 If the file becomes inaccessible or it is closed behind the class's back, an exception will be thrown
 or it will crash.
*/

class ABigBinaryFile {
	private(set) var dataSize : UInt64 = 0
	
	private(set) var fileDesc : Int32 = -1
	private(set) var path : String? = nil
	private var F : UnsafeMutablePointer<FILE>? = nil
	private var lastCheck : timespec!
	
	private(set) var blockSize : UInt16!
	// Size of last block in file. It will probably not be blockSize in size.
	var lastBlockSize : UInt16 { return UInt16(dataSize % UInt64(blockSize)) }
	// Total number of blocks the file uses.
	private(set) var blockCount : UInt64!
	// Maximum number of blocks.
	private(set) var maxBlocks : UInt64!
	
	// File cache.
	private var blockArray : [MemoryBlob] = []
	// Key is block#, value is index into blockArray.
	private var blockNumAddr : [UInt64:Int] = [:]
	// Oldest block will be in the front of the array.
	private var blkNumberHistory : [UInt64] = []
	// Which memory blobs in block array are free for use.
	private var freeSections : [Bool] = []
	
	// File desciptor initialiser.
	init?(desc : Int32, blockSz : UInt16, maxBlks : UInt64) throws {
		if blockSz < 256 || maxBlks == 0 || desc < 4 { return nil }
		
		fileDesc = desc
		blockSize = blockSz
		maxBlocks = maxBlks
		
		blockArray = Array(repeating: MemoryBlob(lump:blockSize), count: Int(maxBlks) )
		freeSections = Array(repeating: false, count: Int(maxBlks) )
		
		lastCheck = timespec(tv_sec: __darwin_time_t.min, tv_nsec: 0)
		
		try FileCheck()
		try OpenFile()
	}
	
	// File path initialiser.
	init?(path P : String, blockSz : UInt16, maxBlks : UInt64) throws {
		if blockSz < 256 || maxBlks == 0 || P.isEmpty { return nil }
		
		path = P
		blockSize = blockSz
		maxBlocks = maxBlks
		
		blockArray = Array(repeating: MemoryBlob(lump:blockSize), count: Int(maxBlks) )
		freeSections = Array(repeating: false, count: Int(maxBlks) )
		
		lastCheck = timespec(tv_sec: __darwin_time_t.min, tv_nsec: 0)
		
		try FileCheck()
		try OpenFile()
	}
	
	// Close FILE.
	deinit {
		if F != nil { fclose(F) }
	}
	
	//-----------------------------
	// MARK:-
	
	// Attempts to open file
	private func OpenFile() throws {
		if F != nil { return }
		
		if path != nil {
			F = fopen(path!, "r")
		}
		else {
			F = fdopen(fileDesc, "r")
		}
		
		if F == nil {
			throw ABinaryFileEx.cannotOpenFile
		}
	}
	
	// Check the file path or desc and make sure it is a simple file
	// and we can access it.
	// If its modification date is after the current, reset everything.
	private func FileCheck() throws {
		var st = stat()
		
		var res : Int32 = 0
		
		if path == nil {
			res = fstat(fileDesc, &st)
		}
		else {
			res = stat(path, &st)
		}
		
		if res != 0 { throw ABinaryFileEx.fileAccessEx }
		
		if (st.st_mode & S_IFMT) != S_IFREG { throw ABinaryFileEx.notAFileEx }
		
		if lastCheck.tv_sec == __darwin_time_t.min {
			lastCheck = st.st_mtimespec
		}
		else {
			if lastCheck.tv_sec < st.st_mtimespec.tv_sec
					|| (lastCheck.tv_sec == st.st_mtimespec.tv_sec && lastCheck.tv_nsec < st.st_mtimespec.tv_nsec) {
				DataReset()
			}
		}
		
		dataSize = UInt64(st.st_size)
		blockCount = dataSize > 0 ? (dataSize - 1) / UInt64(blockSize) + 1 : 0
	} // FileCheck()
	
	// Underlying file has changed or the user has requested it.
	// Cache is purged.
	private func DataReset() {
		for var m in blockArray {
			m.Zero()
		}
		
		freeSections = Array(repeating: false, count: Int(maxBlocks))
		blockNumAddr.removeAll()
		blkNumberHistory.removeAll()
	}
	
	/// Set to true if you want old blocks zeroed when purged/reused.
	var zeroBlocks : Bool = false
	
	// Zero passed block
	private func Zero(block: Int) {
		if zeroBlocks {
			blockArray[block].Zero()
		}
	}
	
	/// Assumes caller has checked against blockCount
	private func Load(block: UInt64) throws {
		if blockNumAddr[block] != nil { return }
		
	//	print("Loading block \(block)")
		
		// Cache is full, toss oldest.
		if blockNumAddr.count == maxBlocks {
			let oldest = blkNumberHistory.first!
			let addr = blockNumAddr[oldest]!
			
			Zero(block: addr)
			freeSections[addr] = false
			blockNumAddr[oldest] = nil
			blkNumberHistory.removeFirst()
			
	//		print("Purging block \(oldest)")
		}
		
		// Find first available memory blob.
		let idx = freeSections.firstIndex { (B) -> Bool in
			return !B
		}!
		
		// Set file position
		var pos  : fpos_t = fpos_t(block * UInt64(blockSize))
		let res = fsetpos(F, &pos)
		if res != 0 {
			throw ABinaryFileEx.fileAccessEx
		}
		
		// Load chunk from file.
		let ptr = UnsafeMutableRawPointer.allocate(byteCount: Int(blockSize), alignment: 1)
		let ct : size_t = fread(ptr, 1, Int(blockSize), F)
		if ct < blockSize && block != blockCount - 1 {
			throw ABinaryFileEx.fileAccessEx
		}
		
		// Assign loaded data to memory blob
		blockArray[idx].SetData(ptr: ptr, count: UInt16(ct))
		ptr.deallocate()
		freeSections[idx] = true
		blkNumberHistory.append(block)
		blockNumAddr[block] = idx
		
	}
	
	/// Preload a block.
	func Preload(block: UInt64) throws {
		if block < blockCount {
			try Load(block: block)
		}
	}
	
	// subscript
	subscript(index : UInt64) -> UInt8? {
		if index >= dataSize { return nil }
		
	//	print("Retrieving byte \(index)")
		
		let blkNum = index / UInt64(blockSize)
		let idx = index % UInt64(blockSize)
		
		do {
			try Load(block: blkNum)
		}
		catch { return nil }
		
		let aryIdx = blockNumAddr[blkNum]
		
		return blockArray[aryIdx!][UInt16(idx)]
	}
	
	// range subscript. Recursive.
	subscript(range: Range<UInt64>) -> [UInt8]? {
		let length = range.upperBound - range.lowerBound
		
	//	if length > blockSize { return nil }
		if range.upperBound > dataSize { return nil }
		// Trivial checks.
		if length == 0 { return [] }
		if length == 1 { return [self[range.lowerBound]!] }
		
		let startBlock = range.lowerBound / UInt64(blockSize)
		let endBlock = (range.upperBound - 1) / UInt64(blockSize)
		
		// range is same block
		if startBlock == endBlock {
			do {
				try Load(block: startBlock)
				let aryIdx = blockNumAddr[startBlock]!
				return try blockArray[aryIdx].Get(NBytes: UInt16(length), from: UInt16(range.lowerBound % UInt64(blockSize)) )
			}
			catch { return nil }
		}
		
	//	let wholeBlockCount = endBlock - startBlock - 2
		let lowerIdx = UInt16(range.lowerBound % UInt64(blockSize))
		let lowerLength = blockSize - lowerIdx
		
		// first block
		let sbIdx = range.lowerBound
		let sbEnd = sbIdx + UInt64(lowerLength)
		guard var ary = self[ sbIdx..<sbEnd ] else { return nil }
		
		// middle blocks
		// Always blockSize aligned and blockSize size.
		for idx in (startBlock + 1)..<endBlock {
			let midIdx = UInt64(idx) * UInt64(blockSize)
			let endIdx = midIdx + UInt64(blockSize)
			guard let addArray = self[ midIdx..<endIdx ] else { return nil }
			ary.append(contentsOf: addArray)
		}
		
		// end block
		let ebEnd = endBlock * UInt64(blockSize)
		guard let addArray = self[ ebEnd..<range.upperBound ] else { return nil }
		ary.append(contentsOf: addArray)
		
		return ary
	}
	
	/// Copy a block from internal storage or disk.
	/// This method will not load into the cache.
	func Copy(block: UInt64) -> MemoryBlob? {
		if block >= blockCount { return nil }
		
		// Check if we already have it loaded.
		if let idx = blockNumAddr[block] {
			return MemoryBlob.init(other: blockArray[idx])
		}
		
		var pos  : fpos_t = fpos_t(block * UInt64(blockSize))
		let res = fsetpos(F, &pos)
		if res != 0 { return nil }
		
		let ptr = UnsafeMutableRawPointer.allocate(byteCount: Int(blockSize), alignment: 1)
		let ct : size_t = fread(ptr, 1, Int(blockSize), F)
		
		var blob = MemoryBlob.init(lump:blockSize)
		blob.SetData(ptr: ptr, count: UInt16(ct))
		ptr.deallocate()
		
		return blob
	}
	
	/// Attempts to load the entire file into memory.
	/// It is all or nothing.
	/// Does not purge the cache.
	func AllData() throws -> Data {
		
		let ptr = UnsafeMutableRawPointer.allocate(byteCount: Int(dataSize), alignment: 1)
		var pos  : fpos_t = 0
		if fsetpos(F, &pos) != 0 {
			throw ABinaryFileEx.fileLoadFail
		}
		
		if fread(ptr, Int(dataSize), 1, F) == 0 {
			throw ABinaryFileEx.fileLoadFail
		}
		
		return Data.init(bytes: ptr, count: Int(dataSize) )
	}
}
