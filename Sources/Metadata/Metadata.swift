//
//  Metadata.swift
//  
//
//  Created by Bil Moorhead on 12/24/19.
//

import Foundation

@dynamicMemberLookup
public struct Metadata: Codable {
	
	public typealias Information = [String:Any]
	public typealias Keys = Information.Keys
	
	var information: Information
	public subscript(dynamicMember member:String) ->Any? {
		
		get { information[member] }
		set { information[member] = newValue }
		
	}
	
	public init(information: Information) {
		
		self.information = information
		
	}
	
}

extension Metadata: CustomStringConvertible {
	
	public var description: String { information.description }
	
}

extension Metadata {
	
	public init(from decoder: Decoder) throws {

		self.information = try Generic.decode(decoder: decoder)
		
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
