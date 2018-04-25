//
//  CommentsTestCase.swift
//  CommentsTestCase
//
//  Created by Zsolt Mikola
//  Copyright © 2018 Zsolt Mikola. All rights reserved.
//

import XCTest
@testable import Consumer

class CommentsTestCase: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(URLProtocolMock.self)
    }

    func testThatPostCommentsIsWorking(){
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts/42/comments") else { return }

        URLProtocolMock.add(mock: self.httpMessage(from: "PostComments.HTTPMessage"), for: url.absoluteString)

        let returnedResultExpectation = expectation(description: "Expected a result")

        let vc = CommentsViewController(nibName: nil, bundle: nil)
        vc.postComments(completionHandler: { data, response, error in
            print(String(data: data!, encoding: String.Encoding.utf8) ?? "")
            returnedResultExpectation.fulfill()
        })

        waitForExpectations(timeout: 0.5)
    }
    
}
