//
//  Metadata.swift
//  
//
//  Created by Bil Moorhead on 12/24/19.
//

import Foundation
import Logger

fileprivate let logger = Logger[Metadata.self]

@dynamicMemberLookup
public struct Metadata: Codable {
	
	public typealias Information = [String:Any]
	public typealias Keys = Information.Keys
	
	var information: Information
	public subscript(dynamicMember member:String) ->Any? {
		
		get { information[member] }
		set { information[member] = newValue }
		
	}
	
}

extension Metadata {
	
	public init(from decoder: Decoder) throws {

		let generic = try Generic.decode(decoder: decoder)
		logger.debug( generic )
		
		self.information = generic
		
	}
	
	public func encode(to encoder: Encoder) throws {
		
		try Generic.encode(information, encoder: encoder)
		
	}
}

extension Metadata: ExpressibleByDictionaryLiteral {

	public typealias Key = Information.Key
	public typealias Value = Information.Value
	
	public init(dictionaryLiteral elements: (Key, Value)...) {
		
		self.information = Dictionary(uniqueKeysWithValues: elements)
		
	}
	
}

extension Metadata {
	
	public init(consume: Any) {
		
		self.init()
		
		let mirror = Mirror(reflecting: consume)
		
		self.information = mirror
			.children
			.filter { $0.label != nil }
			.reduce(into: [:]) { $0[$1.label!] = $1.value }

	}
	
}

extension Metadata {
	
	public var keys: Keys { information.keys }
	
}
