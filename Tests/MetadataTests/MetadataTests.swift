import XCTest
@testable import Metadata

import os

fileprivate let logger = Logger(subsystem: "metadata", category: "creation")


final class MetadataTests: XCTestCase {
 
	func shaEncoder(data: Data, encoder: Encoder) throws {
		
		var container = encoder.singleValueContainer()
		try container.encode(data.hex)
		
	}
	func shaDecoder(decoder: Decoder) throws ->Data {
		
		let container = try decoder.singleValueContainer()
		
		let value = try container.decode(String.self)
		return Data(hexString: value)
		
	}
	
	lazy var decoder: JSONDecoder = {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		decoder.dataDecodingStrategy = .custom(shaDecoder)
		return decoder
	}()

	lazy var encoder: JSONEncoder = {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		encoder.outputFormatting = .prettyPrinted
		encoder.dataEncodingStrategy = .custom(shaEncoder)
		return encoder
	}()
	
	
	func testVanilla() throws {
		
		let parameters: Metadata = [
			"name": "bilm",
			"age": 54,
			"married": true
		]
		logger.debug("\(parameters)")
		
		XCTAssertEqual(parameters.name as? String, "bilm")
		XCTAssertEqual(parameters.age as? Int, 54)
		XCTAssertEqual(parameters.married as? Bool, true)
		XCTAssertNil(parameters.employed as? Bool)
		XCTAssertNil(parameters[dynamicMember: "birthday"] as? Date)
		
	}

	func testKeys() throws {
		
		let parameters: Metadata = [
			"name": "bilm",
			"age": 54,
			"married": true
		]
		logger.debug("\(parameters)")
		
		XCTAssertEqual(Array(parameters.keys).sorted(), ["age", "married", "name"])
		
	}
	
	func testDecoding() throws {
		
		let raw = """
		{
			"name": "bilm",
			"age": 54,
			"married": true
		}
		"""
		let data = Data( raw.utf8 )
		
		let parameters = try decoder.decode(Metadata.self, from: data)
		logger.debug("\(parameters)")
		
		XCTAssertEqual(parameters.name as? String, "bilm")
		XCTAssertEqual(parameters.age as? Int, 54)
		XCTAssertEqual(parameters.married as? Bool, true)
		XCTAssertNil(parameters.employed as? Bool)
		XCTAssertNil(parameters[dynamicMember: "birthday"] as? Date)

	}

	func testEncoding() throws {
		
		let parameters: Metadata = [
			"name": "bilm",
			"age": 54,
			"married": true
		]
		logger.debug("\(parameters)")

		let data = try encoder.encode(parameters)
		let message = String(data: data, encoding: .utf8) ?? "«»"
		logger.debug("\(message)")
		
		
	}

	func testExtendedEncoding() throws {
		
		let parameters: Metadata = [
			"name": "bilm",
			"age": 54,
			"married": true,
			"spouse": [
				"name": "margoj",
				"age": 54
			],
			"scores": [ true, true, false ],
			"address": (nil as String?) as Any
		]
		logger.debug("\(parameters)")

		let data = try encoder.encode(parameters)
		let message = String(data: data, encoding: .utf8) ?? "«»"
		logger.debug("\(message)")
		print(message)
		
		
	}
	
	func testExtendedDecoding() throws {
		
		let raw = """
		{
			"name": "bilm",
			"age": 54,
			"married": true,
			"spouse": {
				"name": "margoj",
				"age": 54
			},
			"scores": [ true, true, false ]
		}
		"""
		let data = Data( raw.utf8 )
		
		let parameters = try decoder.decode(Metadata.self, from: data)
		logger.debug("\(parameters)")
		
		XCTAssertEqual(parameters.name as? String, "bilm")
		XCTAssertEqual(parameters.age as? Int, 54)
		XCTAssertEqual(parameters.married as? Bool, true)
		XCTAssertNil(parameters.employed as? Bool)
		XCTAssertNil(parameters[dynamicMember: "birthday"] as? Date)

		let message = parameters.spouse as? [String:Any] ?? [:]
		logger.debug("\(message)")

	}

	func testReferenceData() throws {
	
		let sha = Data("bilm".utf8)
		let ref = ReferenceData(imageSHA: sha)
		logger.debug("0, \(ref)")
		
		let data = try encoder.encode(ref)
		let json = String(data: data, encoding: .utf8) ?? "«»"
		
		print(json)
//		logger.debug( json )
		
		let metadata = try decoder.decode(Metadata.self, from: data)
		logger.debug("2, \(metadata)")
		
		let reference = try decoder.decode(ReferenceData.self, from: data)
		logger.debug("3, \(reference)")
	}

	func testConsume() throws {
		
		let sha = Data("bilm".utf8)
		let ref = ReferenceData(author: "liam", imageSHA: sha)
		logger.debug("0, \(ref)")

		var metadata = Metadata(consume: ref)
		logger.debug("1, \(metadata)")
		
		metadata.label = "mine"
		logger.debug("2, \(metadata)")
		
		let data = try encoder.encode(metadata)
		let json = String(data: data, encoding: .utf8) ?? "«»"
		print(3, json)
		
		let reference = try decoder.decode(ReferenceData.self, from: data)
		logger.debug("4, \(reference)")
		
	}
	
	func testHierarchy() throws {
		
		let sha = Data("bilm".utf8)
		let ref = ReferenceData(author: "liam", imageSHA: sha)
		var metadata = Metadata()
		
		metadata.label = "mine"
		metadata.details = ref

		let data = try encoder.encode(metadata)
		let json = String(data: data, encoding: .utf8) ?? "«»"
		print(0, json)
		
	}
	
	func testViaDictionary() throws {
		
		let dict: Metadata.Information = [
			"name": "bilm",
			"age": 54,
			"married": true
		]
		
		let metadata = Metadata(information: dict)
		print( metadata )
		
	}
}

//
//

extension Data {
	
	public var hex: String { 
		
		map{ String(format: "%02x", $0) }
		.joined(separator: "")
		
	}
	
	public init(hexString: String) {
		
		self.init()
		
		hexString
			.chunks(of: 2)
			.lazy
			.forEach { append( UInt8( $0, radix: 16)! ) }
		
	}
	
}

extension StringProtocol {
	
	public func chunks(of n: Int) ->[SubSequence] {
		
		var chunks: [SubSequence] = []
		var idx = startIndex
		while let nxt = index(idx, offsetBy: n, limitedBy: endIndex) {
			
			chunks.append( self[idx..<nxt] )
			idx = nxt
			
		}
		return chunks
		
	}

}

//
//

struct ReferenceData: CustomStringConvertible, Codable {
	
	var requestId = UUID().uuidString.lowercased()
	var timestamp = Date()

	var author: String?
	var source = AppVersion()

	var imageSHA: Data?

	var description: String {
		
		"ReferenceData("
		+ "requestId: \(requestId)"
		+ ", timestamp: \(timestamp)"
		+ (author.flatMap { ", author: \($0)" } ?? "")
		+ ", source: \(source)"
		+ (imageSHA.flatMap { ", imageSHA: \($0)" } ?? "")
		+ ")"
		
	}
	
}

public final class AppVersion: CustomStringConvertible, Codable {
	
	let name: String?
	let version: String
	
	init() {
		
		let bundle = Bundle.main
		
		let objName = bundle.object(forInfoDictionaryKey: "CFBundleName")
		self.name = objName as? String
		
		let objVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString")
		self.version = (objVersion as? String) ?? "0.0.0"
		
	}
	
	public var description: String { "\(name ?? "«»"), \(version)" }
	
}
