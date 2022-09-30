//
//  Environment.swift
//  PostThis
//
//  Created by Liam Jones on 08/05/2022.
//

import Foundation

struct APIEnvironment {
  let baseUrl: URL
}

extension APIEnvironment {
  static let production = APIEnvironment(baseUrl: URL(string: "http://localhost:8080/api")!)
  static let local80 = APIEnvironment(baseUrl: URL(string: "http://localhost:8080/postthis/api")!)
  static let local81 = APIEnvironment(baseUrl: URL(string: "http://localhost:8081/postthis/api")!)
}
