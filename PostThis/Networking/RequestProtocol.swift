//
//  RequestProtocol.swift
//  PostThis
//
//  Created by Liam Jones on 08/05/2022.
//

import Foundation

enum HttpMethod: String {
  case GET, POST, PUT, DELETE
}

protocol RequestProtocol {
  associatedtype Response
  
  var method: HttpMethod { get }
  var path: String { get }
  var authHeader: String? { get }
  var body: Data? { get }
  
  func handle(data: Data) async throws -> Response
}
