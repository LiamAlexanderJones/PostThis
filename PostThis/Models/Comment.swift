//
//  Comment.swift
//  PostThis
//
//  Created by Liam Jones on 08/05/2022.
//

import Foundation
import UIKit

struct Comment: Codable, Identifiable, StatementProtocol {
  
  var postID: UUID?
  var id: UUID?
  var body: String
  var createdAt: Date
  var createdBy: User.Public
  var hasImage: Bool
  
  init(id: UUID? = nil, postID: UUID? = nil, body: String, createdAt: Date = Date(), username: String = "", hasImage: Bool) {
    self.id = id
    self.postID = postID
    self.body = body
    self.createdAt = createdAt
    self.createdBy = User.Public(username: username)
    self.hasImage = hasImage
  }
  
}

