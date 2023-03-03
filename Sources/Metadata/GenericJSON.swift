//
//  Generic.swift
//  
//
//  Created by Bil Moorhead on 12/18/19.
//

import Foundation

// MARK: Definition

enum Generic {
	
	case toplevelDecoder
	case toplevelEncoder
	
}

// MARK: Key definition

extension Generic {
	
	struct Key: CodingKey {
		
		var stringValue: String
		var intValue: Int?
		
		init?(stringValue: String) { self.stringValue = stringValue }
		init?(intValue: Int) { 
			
			self.stringValue = "\(intValue)"
			self.intValue = intValue
		
		}
		
	}
	
}

// MARK: Decode functions

extension Generic {
	
	static func decode(decoder: Decoder) throws ->[String:Any] {
		
		let root = try decoder.container(keyedBy: Key.self)
		return toplevelDecoder.keyed(root)

	}
	
	//

	func unkeyed(_ container: UnkeyedDecodingContainer) -> [Any] {
		
		var list: [Any] = []
		var container = container
		
		while !container.isAtEnd {
			
			if let array = try? container.nestedUnkeyedContainer() { list.append( unkeyed(array) ) }
			else if let dictionary = try? container.nestedContainer(keyedBy: Key.self) { list.append( keyed(dictionary) ) }
			else if let bool = try? container.decode(Bool.self) { list.append(bool) }
			else if let string = try? container.decode(String.self) { list.append(string) }
			else if let int = try? container.decode(Int.self) { list.append(int) }
			else if let int8 = try? container.decode(Int8.self) { list.append(int8) }
			else if let int16 = try? container.decode(Int16.self) { list.append(int16) }
			else if let int32 = try? container.decode(Int32.self) { list.append(int32) }
			else if let int64 = try? container.decode(Int64.self) { list.append(int64) }
			else if let uint = try? container.decode(UInt.self) { list.append(uint) }
			else if let uint8 = try? container.decode(UInt8.self) { list.append(uint8) }
			else if let uint16 = try? container.decode(UInt16.self) { list.append(uint16) }
			else if let uint32 = try? container.decode(UInt32.self) { list.append(uint32) }
			else if let uint64 = try? container.decode(UInt64.self) { list.append(uint64) }
			else if let double = try? container.decode(Double.self) { list.append(double) }
			else if let float = try? container.decode(Float.self) { list.append(float) }
			else if let nothing = try? container.decodeNil() { list.append(nothing) }

		}
		
		return list
	}
	func keyed(_ container: KeyedDecodingContainer<Key>) ->[String:Any] {

		var mapping: [String:Any] = [:]

		container.allKeys.forEach {
			key in

			if let dictionary = try? container.nestedContainer(keyedBy: Key.self, forKey: key) { mapping[key.stringValue] = keyed(dictionary) }
			else if let array = try? container.nestedUnkeyedContainer(forKey: key) { mapping[key.stringValue] = unkeyed(array) }
			else if let bool = try? container.decode(Bool.self, forKey: key) { mapping[key.stringValue] = bool }
			else if let string = try? container.decode(String.self, forKey: key) { mapping[key.stringValue] = string }
			else if let int = try? container.decode(Int.self, forKey: key) { mapping[key.stringValue] = int }
			else if let int8 = try? container.decode(Int8.self, forKey: key) { mapping[key.stringValue] = int8 }
			else if let int16 = try? container.decode(Int16.self, forKey: key) { mapping[key.stringValue] = int16 }
			else if let int32 = try? container.decode(Int32.self, forKey: key) { mapping[key.stringValue] = int32 }
			else if let int64 = try? container.decode(Int64.self, forKey: key) { mapping[key.stringValue] = int64 }
			else if let uint = try? container.decode(UInt.self, forKey: key) { mapping[key.stringValue] = uint }
			else if let uint8 = try? container.decode(UInt8.self, forKey: key) { mapping[key.stringValue] = uint8 }
			else if let uint16 = try? container.decode(UInt16.self, forKey: key) { mapping[key.stringValue] = uint16 }
			else if let uint32 = try? container.decode(UInt32.self, forKey: key) { mapping[key.stringValue] = uint32 }
			else if let uint64 = try? container.decode(UInt64.self, forKey: key) { mapping[key.stringValue] = uint64 }
			else if let double = try? container.decode(Double.self, forKey: key) { mapping[key.stringValue] = double }
			else if let float = try? container.decode(Float.self, forKey: key) { mapping[key.stringValue] = float }
			else if let nothing = try? container.decodeNil(forKey: key) { mapping[key.stringValue] = nothing }
			
		}

		return mapping
	}

}

// MARK: Encode functions

extension Generic {
	
	static func encode(_ generic: [String:Any], encoder: Encoder) throws {
		
		let root = encoder.container(keyedBy: Key.self)
		try toplevelEncoder.keyed(generic, container: root)
		
	}
	
	func unkeyed(_ generic: [Any], container: UnkeyedEncodingContainer) throws {
		
		var container = container
		try generic.forEach {
			
			switch $0 {
			case let dictionary as [String:Any]: try keyed(dictionary, container: container.nestedContainer(keyedBy: Generic.Key.self))
			case let array as [Any]: try unkeyed(array, container: container.nestedUnkeyedContainer())
			case let bool as Bool: try container.encode(bool)
			case let string as String: try container.encode(string)
			case let int as Int: try container.encode(int)
			case let int8 as Int8: try container.encode(int8)
			case let int16 as Int16: try container.encode(int16)
			case let int32 as Int32: try container.encode(int32)
			case let int64 as Int64: try container.encode(int64)
			case let uint as UInt: try container.encode(uint)
			case let uint8 as UInt8: try container.encode(uint8)
			case let uint16 as UInt16: try container.encode(uint16)
			case let uint32 as UInt32: try container.encode(uint32)
			case let uint64 as UInt64: try container.encode(uint64)
			case let double as Double: try container.encode(double)
			case let float as Float: try container.encode(float)
			case let date as Date: try container.encode(date)
			case let data as Data: try container.encode(data)
			case let value as Encodable: try container.encode(value)
			case Optional<Any>.none: try container.encodeNil()
			case Optional<Any>.some(let value):
				
				let mirror = Mirror(reflecting: value)
				let dictionary:[String:Any] = mirror
					.children
					.filter { $0.label != nil }
					.reduce(into: [:]) { $0[$1.label!] = $1.value }
				try keyed(dictionary, container: container.nestedContainer(keyedBy: Generic.Key.self))

			default:
				
				guard case Optional<Any>.none = $0 else {
					
					try container.encodeNil()
					return 
					
				}
				
				let mirror = Mirror(reflecting: $0)
				let dictionary:[String:Any] = mirror
					.children
					.filter { $0.label != nil }
					.reduce(into: [:]) { $0[$1.label!] = $1.value }
				try keyed(dictionary, container: container.nestedContainer(keyedBy: Generic.Key.self))
				
			}
			
		}
		
	}
	func keyed(_ generic: [String:Any], container: KeyedEncodingContainer<Key>) throws {
		
		var container = container
		try generic.keys
			.compactMap { Key(stringValue: $0) }
			.forEach {
				
				switch generic[$0.stringValue] {
				case let dictionary as [String:Any]: try keyed(dictionary, container: container.nestedContainer(keyedBy: Generic.Key.self, forKey: $0))
				case let array as [Any]: try unkeyed(array, container: container.nestedUnkeyedContainer(forKey: $0))
				case let bool as Bool: try container.encode(bool, forKey: $0)
				case let string as String: try container.encode(string, forKey: $0)
				case let int as Int: try container.encode(int, forKey: $0)
				case let int8 as Int8: try container.encode(int8, forKey: $0)
				case let int16 as Int16: try container.encode(int16, forKey: $0)
				case let int32 as Int32: try container.encode(int32, forKey: $0)
				case let int64 as Int64: try container.encode(int64, forKey: $0)
				case let uint as UInt: try container.encode(uint, forKey: $0)
				case let uint8 as UInt8: try container.encode(uint8, forKey: $0)
				case let uint16 as UInt16: try container.encode(uint16, forKey: $0)
				case let uint32 as UInt32: try container.encode(uint32, forKey: $0)
				case let uint64 as UInt64: try container.encode(uint64, forKey: $0)
				case let double as Double: try container.encode(double, forKey: $0)
				case let float as Float: try container.encode(float, forKey: $0)
				case let date as Date: try container.encode(date, forKey: $0)
				case let data as Data: try container.encode(data, forKey: $0)
				case let value as Encodable: try container.encode(value, forKey: $0)
				case .none: try container.encodeNil(forKey: $0)
				case .some(let value):
					
					let mirror = Mirror(reflecting: value)
					let dictionary:[String:Any] = mirror
						.children
						.filter { $0.label != nil }
						.reduce(into: [:]) { $0[$1.label!] = $1.value }
					try keyed(dictionary, container: container.nestedContainer(keyedBy: Generic.Key.self, forKey: $0))

				}
				
			}
		
	}
}
