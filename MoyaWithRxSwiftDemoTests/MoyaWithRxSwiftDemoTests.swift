//
//  MoyaWithRxSwiftDemoTests.swift
//  MoyaWithRxSwiftDemoTests
//
//  Created by Ficow on 2019/11/19.
//  Copyright © 2019 ficow. All rights reserved.
//

import XCTest
import Moya
import RxBlocking
@testable import MoyaWithRxSwiftDemo

class MoyaWithRxSwiftDemoTests: XCTestCase {

    func testHomeAPI() {
        guard let url = URL(string: "https://apple.com") else {
            XCTFail()
            return
        }
        var api = HomeAPI(baseURL: url, endpoint: .basicInfo)
        XCTAssertEqual(api.path, "basic_info.json")
        api = HomeAPI(baseURL: url, endpoint: .hobbies)
        XCTAssertEqual(api.path, "hobbies.json")
    }
    
    func testSuccessfulHomeAPIRequest() {
        guard let url = URL(string: "https://apple.com"),
            let basicInfoData = loadDataInJSONFile(fileName: "basic_info") else {
            XCTFail()
            return
        }
        
        let provider = MoyaProvider<HomeAPI>(endpointClosure: { self.mockEndpointForAPI(api: $0, response: .networkResponse(200, basicInfoData)) },
                                             stubClosure: { _ in .immediate })
        let apiHelper = HomeNetworkHelper(baseURL: url, moyaProvider: provider)
        guard let basicInfo = try? apiHelper.fetchBasicInfo().toBlocking().first() else {
            XCTFail()
            return
        }
        XCTAssertEqual(basicInfo.name, "John")
        XCTAssertEqual(basicInfo.age, 10)
    }

    func testNetworkErrorForHomeAPIRequest() {
        guard let url = URL(string: "https://apple.com") else {
            XCTFail()
            return
        }
        let expectedError = NSError(domain: "expectedError", code: -1, userInfo: nil)
        let provider = MoyaProvider<HomeAPI>(endpointClosure: { self.mockEndpointForAPI(api: $0, response: .networkError(expectedError)) },
                                             stubClosure: { _ in .immediate })
        let apiHelper = HomeNetworkHelper(baseURL: url, moyaProvider: provider)
        expectError(expectedError) {
            _ = try apiHelper.fetchBasicInfo().toBlocking().first()
        }
    }

    func testResponseErrorForHomeAPIRequest() {
        guard let url = URL(string: "https://apple.com") else {
            XCTFail()
            return
        }
        let expectedError = NSError(domain: "", code: 404, userInfo: nil)
        let provider = MoyaProvider<HomeAPI>(endpointClosure: {
            self.mockEndpointForAPI(api: $0, response: .networkResponse(404, Data())) },
        stubClosure: { _ in .immediate })
        let apiHelper = HomeNetworkHelper(baseURL: url, moyaProvider: provider)
        expectError(expectedError) {
            _ = try apiHelper.fetchBasicInfo().toBlocking().first()
        }
    }
    
    func mockEndpointForAPI(api: TargetType, response: EndpointSampleResponse) -> Endpoint {
        return Endpoint(url: api.baseURL.absoluteString,
                        sampleResponseClosure: { response },
                        method: api.method,
                        task: api.task,
                        httpHeaderFields: api.headers)
    }
    
    func loadDataInJSONFile(fileName: String) -> Data? {
        let bundle = Bundle(for: type(of: self))
        guard let filePath = bundle.path(forResource: fileName, ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            return nil
        }
        return data
    }

    func expectError(_ expectedError: NSError, inFailedRequest requestOperation: (() throws -> ())) {
        do {
            try requestOperation()
            XCTFail()
        } catch let error as Moya.MoyaError {
            switch error {
            case let .underlying(error as NSError, response):
                if let response = response {
                    XCTAssertEqual(expectedError.code, response.statusCode)
                } else {
                    XCTAssertEqual(error.code, expectedError.code)
                }
            default:
                XCTFail()
            }
        } catch {
            XCTFail()
        }
    }

}
