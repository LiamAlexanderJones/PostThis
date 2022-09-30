//
//  Post.swift
//  PostThis
//
//  Created by Liam Jones on 08/05/2022.
//

import Foundation
import UIKit

struct Post: Codable, Identifiable, StatementProtocol {
  
  var id: UUID?
  var body: String
  var createdAt: Date
  var createdBy: User.Public
  var hasImage: Bool = false
  
  init(id: UUID? = nil, body: String, createdAt: Date = Date(), username: String = "", hasImage: Bool) {
    self.id = id
    self.body = body
    self.createdAt = createdAt
    self.createdBy = User.Public(username: username)
    self.hasImage = hasImage
  }
  
}
