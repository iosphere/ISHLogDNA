//
//  UnitTests.swift
//  UnitTests
//
//  Created by Hagi on 16.08.17.
//  Copyright © 2017 iosphere. All rights reserved.
//

import XCTest
import ISHLogDNA

class ISHLogDNAMessageTests: XCTestCase {

    func testDefaultMetaData() {
        let messageWithoutMeta = ISHLogDNAMessage(line: "testWithoutMeta", level: .info, meta: nil)
        let messageWithEmptyMeta = ISHLogDNAMessage(line: "testWithEmptyMeta", level: .info, meta: [:])
        let messageWithUserMeta = ISHLogDNAMessage(line: "testWithUserMeta", level: .info, meta: ["custom": 50])

        for message in [messageWithoutMeta, messageWithEmptyMeta, messageWithUserMeta] {
            XCTAssertNotNil(message.meta)
            XCTAssertNotNil(message.meta[ISHLogDNAServiceKeyBundleVersion] as? String)
            XCTAssertNotNil(message.meta[ISHLogDNAServiceKeySystemVersion] as? String)
            XCTAssertNotNil(message.meta[ISHLogDNAServiceKeyModelName] as? String)
        }

        XCTAssertEqual(messageWithUserMeta.meta["custom"] as? Int, 50)
    }

    func testErrorWrapping() {
        let emptyErrorDict = ISHLogDNAMessage.metaDictionaryWithError(nil)
        XCTAssertNotNil(emptyErrorDict)
        XCTAssertTrue(emptyErrorDict.count == 0)

        let domain = "unitTests"
        let simpleError = NSError(domain: domain, code: 0, userInfo: nil)
        let simpleErrorDict = ISHLogDNAMessage.metaDictionaryWithError(simpleError)
        XCTAssertNotNil(simpleErrorDict)
        XCTAssertEqual(simpleErrorDict[ISHLogDNAServiceKeyErrorDomain] as? String, domain)
        XCTAssertEqual(simpleErrorDict[ISHLogDNAServiceKeyErrorCode] as? Int, 0)
        XCTAssertNil(simpleErrorDict[ISHLogDNAServiceKeyErrorDescription])
        XCTAssertNil(simpleErrorDict[ISHLogDNAServiceKeyUnderlyingError])

        let reason = "This is an expected error"
        let errorWithDescription = NSError(domain: domain, code: 50, userInfo: [NSLocalizedFailureReasonErrorKey: reason])
        let errorWithDescriptionDict = ISHLogDNAMessage.metaDictionaryWithError(errorWithDescription)
        XCTAssertNotNil(errorWithDescriptionDict)
        XCTAssertEqual(errorWithDescriptionDict[ISHLogDNAServiceKeyErrorDomain] as? String, domain)
        XCTAssertEqual(errorWithDescriptionDict[ISHLogDNAServiceKeyErrorCode] as? Int, 50)
        XCTAssertEqual(errorWithDescriptionDict[ISHLogDNAServiceKeyErrorDescription] as? String, reason)
        XCTAssertNil(errorWithDescriptionDict[ISHLogDNAServiceKeyUnderlyingError])

        let subdomain = "subdomain"
        let underlyingReason = "Still not the actual reason"
        let underlyingError = NSError(domain: subdomain, code: 10, userInfo: [
            NSLocalizedFailureReasonErrorKey: underlyingReason,
            NSUnderlyingErrorKey: simpleError,
            ])
        let errorWithUnderlyingError = NSError(domain: domain, code: 5, userInfo: [NSUnderlyingErrorKey: underlyingError])
        let errorWithUnderlyingErrorDict = ISHLogDNAMessage.metaDictionaryWithError(errorWithUnderlyingError)
        XCTAssertNotNil(errorWithUnderlyingErrorDict)
        XCTAssertEqual(errorWithUnderlyingErrorDict[ISHLogDNAServiceKeyErrorDomain] as? String, domain)
        XCTAssertEqual(errorWithUnderlyingErrorDict[ISHLogDNAServiceKeyErrorCode] as? Int, 5)
        XCTAssertNil(errorWithUnderlyingErrorDict[ISHLogDNAServiceKeyErrorDescription])

        let underlyingErrorDict = errorWithUnderlyingErrorDict[ISHLogDNAServiceKeyUnderlyingError] as? [String: Any]
        XCTAssertNotNil(underlyingErrorDict)
        XCTAssertEqual(underlyingErrorDict![ISHLogDNAServiceKeyErrorDomain] as? String, subdomain)
        XCTAssertEqual(underlyingErrorDict![ISHLogDNAServiceKeyErrorCode] as? Int, 10)
        XCTAssertEqual(underlyingErrorDict![ISHLogDNAServiceKeyErrorDescription] as? String, underlyingReason)
        // arbitrary dictionaries ("Any") are not equatable directly, so we rely on description
        XCTAssertEqual((underlyingErrorDict![ISHLogDNAServiceKeyUnderlyingError] as? [String: Any])?.description, simpleErrorDict.description)

        let arbitraryUserInfoKey = "entriesInDatabase"
        let userValue = 1234
        let errorWithUserInfo = NSError(domain: domain, code: 27, userInfo: [arbitraryUserInfoKey: userValue])
        let errorWithUserInfoDict = ISHLogDNAMessage.metaDictionaryWithError(errorWithUserInfo)
        XCTAssertNotNil(errorWithUserInfoDict)
        XCTAssertEqual(errorWithUserInfoDict[ISHLogDNAServiceKeyErrorDomain] as? String, domain)
        XCTAssertEqual(errorWithUserInfoDict[ISHLogDNAServiceKeyErrorCode] as? Int, 27)

        // we deliberately do not include random keys from the error's user info as it
        // may contain sensitive information that should not be sent by default
        XCTAssertNil(errorWithUserInfoDict[arbitraryUserInfoKey])
        XCTAssertFalse(errorWithUserInfoDict.values.contains { $0 as? Int == userValue })
    }
    
}
