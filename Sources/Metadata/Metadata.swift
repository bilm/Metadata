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
	
	var information: [String:Any]
	subscript(dynamicMember member:String) ->Any? { information[member] }
	
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

	public typealias Key = String
	public typealias Value = Any
	
	public init(dictionaryLiteral elements: (Key, Value)...) {
		
		self.information = Dictionary(uniqueKeysWithValues: elements)
		
	}
	
}
