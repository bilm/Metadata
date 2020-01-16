import XCTest
@testable import Metadata

@testable import Logger
fileprivate let logger = Logger.DEBUG


final class MetadataTests: XCTestCase {
 
	class GenericJSONTests: XCTestCase {
		
		
		let decoder: JSONDecoder = {
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			return decoder
		}()

		let encoder: JSONEncoder = {
			let encoder = JSONEncoder()
			encoder.dateEncodingStrategy = .iso8601
			encoder.outputFormatting = .prettyPrinted
			return encoder
		}()
		
		
		func testVanilla() throws {
			
			let parameters: Metadata = [
				"name": "bilm",
				"age": 54,
				"married": true
			]
			logger.debug(parameters)
			
			XCTAssertEqual(parameters.name as? String, "bilm")
			XCTAssertEqual(parameters.age as? Int, 54)
			XCTAssertEqual(parameters.married as? Bool, true)
			XCTAssertNil(parameters.employed as? Bool)
			XCTAssertNil(parameters[dynamicMember: "birthday"] as? Date)
			
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
			logger.debug(parameters)
			
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
			logger.debug(parameters)

			let data = try encoder.encode(parameters)
			logger.debug(String(data: data, encoding: .utf8) ?? "«»")
			
			
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
			logger.debug(parameters)

			let data = try encoder.encode(parameters)
			logger.debug(String(data: data, encoding: .utf8) ?? "«»")
			print(String(data: data, encoding: .utf8) ?? "«»")
			
			
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
			logger.debug(parameters)
			
			XCTAssertEqual(parameters.name as? String, "bilm")
			XCTAssertEqual(parameters.age as? Int, 54)
			XCTAssertEqual(parameters.married as? Bool, true)
			XCTAssertNil(parameters.employed as? Bool)
			XCTAssertNil(parameters[dynamicMember: "birthday"] as? Date)

			logger.debug(parameters.spouse as? [String:Any] ?? [:])

		}

	}

}
