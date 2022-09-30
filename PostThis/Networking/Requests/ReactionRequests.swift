//
//  ReactionRequests.swift
//  PostThis
//
//  Created by Liam Jones on 01/08/2022.
//

import Foundation


struct GetReactionsRequest: RequestProtocol {
  typealias Response = Reactors
  
  init(statementID: UUID, isPost: Bool) {
    self.statementPath = isPost ? "posts" : "comments"
    self.statementID = statementID
  }
  
  let statementPath: String
  let statementID: UUID

  var method: HttpMethod { return .GET}
  var path: String { return "/\(statementPath)/\(statementID.uuidString)/reactions" }
  var authHeader: String? { return nil }
  var body: Data? { return nil }
  
  func handle(data: Data) async throws -> Reactors {
    guard let reactors = try? JSONDecoder().decode(Reactors.self, from: data) else {
      throw PostThisError.decodingError
    }
    return reactors
  }
}

struct ReactionRequest: RequestProtocol {
  typealias Response = Void
  
  init(statementID: UUID, isPost: Bool, reactionType: ReactionType, hasReaction: Bool) {
    self.statementPath = isPost ? "posts" : "comments"
    self.statementID = statementID
    self.reactionType = reactionType
    self.hasReaction = hasReaction
  }
  
  let statementPath: String
  let statementID: UUID
  let reactionType: ReactionType
  let hasReaction: Bool
  
  //If the statement already has a reaction, we remove it. It not, we add a reaction.
  var method: HttpMethod { return hasReaction ? .DELETE : .POST}
  var path: String { return "/\(statementPath)/\(statementID.uuidString)/\(reactionType)" }
  var authHeader: String? { return "Bearer \(UserSettings.shared.token?.value ?? "")" }
  var body: Data? { return nil }
  
  func handle(data: Data) async throws -> Void {  }
}


