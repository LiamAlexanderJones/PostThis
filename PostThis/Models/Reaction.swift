//
//  Reaction.swift
//  PostThis
//
//  Created by Liam Jones on 08/05/2022.
//

import Foundation

enum ReactionType: String, Codable, CaseIterable {
  case like, up, down
  
  func imageString() -> String {
    switch self {
    case .like:
      return "heart"
    case .up:
      return "hand.thumbsup"
    case .down:
      return "hand.thumbsdown"
    }
  }
}

struct Reaction: Codable {
  var reactionType: ReactionType
}

struct Reactors: Codable {
  var likeReactors: [User.Public]
  var upReactors: [User.Public]
  var downReactors: [User.Public]
}



