//
//  AppleSignInControllerTests.swift
//  FlagAppTests
//
//  Created by Anderson on 24/08/20.
//  Copyright © 2020 Flag. All rights reserved.
//
import AuthenticationServices
@testable import FlagApp
import XCTest

class AppleSignInControllerTests: XCTestCase {
    func test_authenticate_performsProperRequest() {
        let spy = ASAuthorizationController.spy
        let sut = SignInWithAppleController()

        sut.authenticate(spy, nonce: "any")

        XCTAssertTrue(spy.delegate === sut, "sut is delegate")
        XCTAssertEqual(spy.performRequestsCallCount, 1, "request request call count")
    }
}

extension ASAuthorizationController {
    static var spy: Spy {
        let dummyRequest = ASAuthorizationAppleIDProvider().createRequest()
        return Spy(authorizationRequests: [dummyRequest])
    }
    class Spy: ASAuthorizationController {
        private(set) var performRequestsCallCount = 0

        override func performRequests() {
            performRequestsCallCount += 1
        }
    }
}
