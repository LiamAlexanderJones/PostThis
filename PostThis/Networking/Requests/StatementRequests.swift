//
//  StatementRequests.swift
//  PostThis
//
//  Created by Liam Jones on 13/07/2022.
//

import Foundation

import Foundation

enum FeedType {
  case global
  case main
  case user
  case comments
}

struct GetStatementsRequest<Statement: StatementProtocol>: RequestProtocol where Statement: Codable {
  //There are now three different ways to get posts. Global feed gets them all; main feed gets your posts and followed posts; and user posts takes a userid in the header. The only thing that needs to change is the path
  typealias Response = [Statement]
  
  init(feedType: FeedType, parentID: UUID? = nil, page: Int = 1, resultsPerPage: Int = UserSettings.resultsPerPage) throws {
    switch feedType {
    case .global:
      feedPath = "/posts/global"
    case .main:
      feedPath = "/posts/main"
    case .user:
      guard let id = parentID?.uuidString else { throw PostThisError.nilParentUserID }
      feedPath = "/users/\(id)/posts"
    case .comments:
      guard let id = parentID?.uuidString else { throw PostThisError.nilParentPostID }
      feedPath = "/posts/\(id)/comments"
    }
    self.page = page
    self.resultsPerPage = resultsPerPage
  }
  
  let page: Int
  let resultsPerPage: Int
  let feedPath: String
  
  var method: HttpMethod { return .GET }
  var path: String { return feedPath + "/\(page)/\(resultsPerPage)" }
  var authHeader: String? { return "Bearer \(UserSettings.shared.token?.value ?? "")" }
  var body: Data? { return nil }
  
  func handle(data: Data) async throws -> [Statement] {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    guard let statements = try? decoder.decode(Response.self, from: data) else {
      throw PostThisError.decodingError
    }
    return statements
  }
}

struct UploadNewStatementRequest<Statement: StatementProtocol>: RequestProtocol where Statement: Codable {
  typealias Response = String
  
  init(caption: String, hasImage: Bool, to parentPostID: UUID? = nil) {
    self.parentPostID = parentPostID
    if let parentPostID = parentPostID, Statement.self == Comment.self {
      self.comment = Comment(postID: parentPostID, body: caption, createdAt: Date(), hasImage: hasImage)
    } else if Statement.self == Post.self {
      self.post = Post(body: caption, createdAt: Date(), hasImage: hasImage)
    }
  }
  
  var post: Post? = nil
  var comment: Comment? = nil
  let parentPostID: UUID?
  
  var method: HttpMethod { return .POST }
  var path: String {
    if let id = parentPostID?.uuidString {
      return "/posts/\(id)/comments"
    } else {
      return "/posts"
    }
  }
  var authHeader: String? { return "Bearer \(UserSettings.shared.token?.value ?? "")" }
  var body: Data? {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    if parentPostID == nil {
      return try? encoder.encode(post)
    } else {
      return try? encoder.encode(comment)
    }
  }
  
  func handle(data: Data) async throws -> String {
    guard let idString = String(data: data, encoding: .ascii) else {
      throw PostThisError.uploadIDFailed
    }
    return idString
  }
}

struct DeleteStatementRequest: RequestProtocol {
  typealias Response = Void
  
  init(statementID: UUID, isPost: Bool) {
    self.statementID = statementID
    self.isPost = isPost
  }
  
  let statementID: UUID
  let isPost: Bool
  
  var method: HttpMethod { return .DELETE }
  var path: String {
    if isPost {
      return "/posts/\(statementID.uuidString)"
    } else {
      return "/comments/\(statementID.uuidString)"
    }
  }
  var authHeader: String? { return "Bearer \(UserSettings.shared.token?.value ?? "")" }
  var body: Data? { return nil }
  
  func handle(data: Data) async throws -> Void { }
}





