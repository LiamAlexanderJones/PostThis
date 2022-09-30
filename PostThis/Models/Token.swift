//
//  Token.swift
//  PostThis
//
//  Created by Liam Jones on 18/07/2022.
//

import Foundation

struct Token: Codable, Equatable {
  var id: UUID?
  var value: String
}
