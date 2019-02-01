//
//  ThreadValue.swift
//  Swift-Utilities
//
//  Created by tridiak on 9/12/18.
//  Copyright © 2018 tridiak. All rights reserved.
//

import Foundation

class ThreadValue<T> {
	private var threadObject : [UInt64 : T] = [:]
	
	private var mutex : pthread_mutex_t!
	
	init?() {
		let res = pthread_mutex_init(&mutex, nil)
		if res != 0 { return nil }
		
	}
	
	deinit {
		pthread_mutex_destroy(&mutex)
	}
	
	//----------------------
	static func ThreadID() -> UInt64 {
		var i : UInt64 = 0
		pthread_threadid_np(pthread_self(), &i)
		
		return i
	}
	
	func SetThreadValue(value : T) -> Bool {
		let I = ThreadValue<T>.ThreadID()
		
		if (pthread_mutex_lock(&mutex) != 0) { return false }
		
		threadObject[I] = value
		
		pthread_mutex_unlock(&mutex)
		
		return true
	}
	
	func GetThreadValue() -> T? {
		let I = ThreadValue<T>.ThreadID()
		
		if (pthread_mutex_lock(&mutex) != 0) { return nil }
		
		let V = threadObject[I]
		
		pthread_mutex_unlock(&mutex)
		
		return V
	}
	
	func GetThreadValue(value : inout T) -> Bool {
		if let V = GetThreadValue() {
			value = V
			return true
		}
		return false
	}
}
