//
//  UserRequests.swift
//  PostThis
//
//  Created by Liam Jones on 11/05/2022.
//

import Foundation


struct UserLoginRequest: RequestProtocol {
  typealias Response = Void

  init(username: String, password: String) {
    self.username = username
    auth = "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
  }
  
  let auth: String
  let username: String
  
  var method: HttpMethod { return .POST }
  var path: String { return "/users/login" }
  var authHeader: String? { return "Basic \(auth)" }
  var body: Data? { return nil }
  
  func handle(data: Data) async throws -> Void {
    guard let token = try? JSONDecoder().decode(Token.self, from: data) else {
      throw PostThisError.decodingError
    }
    DispatchQueue.main.async {
      UserSettings.shared.token = token
      UserSettings.shared.username = username
      UserSettings.shared.loggedIn = true
    }
  }
}

struct UserCreateAccountRequest: RequestProtocol {
  typealias Response = Void

  init(username: String, password: String, confirmPassword: String) {
    user = User.Create(username: username, password: password, confirmPassword: confirmPassword)
    auth = "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
  }
  
  let user: User.Create
  let auth: String
  
  var method: HttpMethod { return .POST }
  var path: String { return "/users" }
  var authHeader: String? { return "Basic \(auth)" }
  var body: Data?  {
    return try? JSONEncoder().encode(user)
  }
  
  func handle(data: Data) async throws -> Void {
    guard let token = try? JSONDecoder().decode(Token.self, from: data) else {
      throw PostThisError.decodingError
    }
    DispatchQueue.main.async {
      UserSettings.shared.token = token
      UserSettings.shared.username = user.username
      UserSettings.shared.loggedIn = true
    }
  }
}

//MARK: -Following Other users

struct GetFollowedUsersRequest: RequestProtocol {
  typealias Response = [User.Public]
  
  var method: HttpMethod { return .GET }
  var path: String { return "/users/followed" }
  var authHeader: String? { return "Bearer \(UserSettings.shared.token?.value ?? "")" }
  var body: Data?  { return nil }
  
  func handle(data: Data) async throws -> [User.Public] {
    let followedUsers = try JSONDecoder().decode([User.Public].self, from: data)
    return followedUsers
  }
}

struct FollowRequest: RequestProtocol {
  typealias Response = Void
  
  let id: UUID
  
  init(id: UUID) {
    self.id = id
  }
  
  var method: HttpMethod { return .POST }
  var path: String { return "/users/follow/\(id.uuidString)" }
  var authHeader: String? { return "Bearer \(UserSettings.shared.token?.value ?? "")" }
  var body: Data? { return nil }
  
  func handle(data: Data) async throws -> Void { }
}








