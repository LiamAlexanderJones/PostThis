//
//  APIClient.swift
//  PostThis
//
//  Created by Liam Jones on 08/05/2022.
//

import Foundation




struct APIClient {
  
  let session: URLSession
  let environment: APIEnvironment
  
  init(session: URLSession = .shared, environment: APIEnvironment = .production) {
    self.session = session
    self.environment = environment
  }
  
  func makeRequest<R: RequestProtocol>(_ request: R) async throws -> R.Response {
    let url = environment.baseUrl.appendingPathComponent(request.path)
    var urlRequest = URLRequest(url: url)
    
    if let authHeader = request.authHeader {
      urlRequest.setValue(authHeader, forHTTPHeaderField: "Authorization")
    }
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.httpMethod = request.method.rawValue
    urlRequest.httpBody = request.body

    let (data, urlResponse) = try await session.data(for: urlRequest)
    
    guard let httpResponse = urlResponse as? HTTPURLResponse,
          200..<300 ~= httpResponse.statusCode
    else {
      let statusCode = (urlResponse as? HTTPURLResponse)?.statusCode ?? 0
      throw PostThisError.networkError(statusCode)
    }
    let response = try await request.handle(data: data)
    return response
  }
  
}
