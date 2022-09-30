//
//  User.swift
//  PostThis
//
//  Created by Liam Jones on 08/05/2022.
//

import Foundation


struct User {
  
  struct Create: Codable, Identifiable {
    
    var id: UUID?
    var username: String
    var password: String
    var confirmPassword: String
    
    init(id: UUID? = nil, username: String, password: String, confirmPassword: String) {
      self.id = id
      self.username = username
      self.password = password
      self.confirmPassword = confirmPassword
    }
  }
  
  struct Public: Codable, Identifiable, Equatable {
    var id: UUID?
    var username: String
  }
  
}


