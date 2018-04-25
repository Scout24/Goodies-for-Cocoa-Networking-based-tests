//
/*
 It's a network component mock which is responsible for returning predefined mocks

 * Important:

 * SeeAlso: HTTPMessage

 * ToDo:

 Copyright © AutoScout24 GmbH. All rights reserved.
 Markup help:https://developer.apple.com/library/content/documentation/Xcode/Reference/xcode_markup_formatting_ref/index.html
 */

import Foundation
@testable import Consumer

final class URLProtocolMock: URLProtocol {

    private static var mocks = [String: [HTTPMessage]]()

    // MARK: Class Request Methods
    // Returns whether it can handle the specified request
    override class func canInit(with request: URLRequest) -> Bool {

        let urlString = request.urlString

        guard let _ = URLProtocolMock.mocks[urlString]?.first else {
            return false
        }

        return true

    }

    // canonical form of a request is used to lookup objects in the URL cache.
    // No caching (requestIsCacheEquivalent) => Can return the original
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    // Let's be sure none of the responses are cached
    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return false
    }

    // MARK: Loading Methods
    override func startLoading() {

        let urlString = request.urlString

        guard let responseMock = URLProtocolMock.mocks[urlString]?.removeFirst() else { return }

        if let _ = URLProtocolMock.mocks[urlString]?.isEmpty {
            URLProtocolMock.mocks.removeValue(forKey: urlString)
        }
        
        guard let response = Foundation.HTTPURLResponse(request: request, message: responseMock), let body = responseMock.body else {
            preconditionFailure()
        }

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: URLCache.StoragePolicy.notAllowed)
        client?.urlProtocol(self, didLoad: body)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}

    static func add(mock: HTTPMessage, for urlString: String) {
        mocks[urlString, default: []].append(mock)
    }
}

// MARK: NSURLSessionDelegate extension
extension URLProtocolMock: URLSessionDelegate {
    func URLSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceiveData data: Data) {
        client?.urlProtocol(self, didLoad: data)
    }

    func URLSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let response = task.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
}

private extension Foundation.HTTPURLResponse {

    convenience init?(request: URLRequest, message: HTTPMessage) {

        guard let url = request.url, let statusCode = message.statusCode else { return nil}

        self.init(url: url, statusCode: statusCode, httpVersion: message.httpVersion, headerFields: message.allHeaderFields)

    }

}

private extension URLRequest {

    var urlString: String {

        guard let urlString = self.url?.absoluteString else {
            preconditionFailure()
        }
        return urlString

    }

}
