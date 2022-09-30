//
//  PostOrCommentProtocol.swift
//  PostThis
//
//  Created by Liam Jones on 13/05/2022.
//

import Foundation
import UIKit

protocol StatementProtocol {
  // A statement is either a post or a comment.
  var id: UUID? { get }
  var body: String { get }
  var createdAt: Date { get }
  var createdBy: User.Public { get }
  var hasImage: Bool { get }
  
}
