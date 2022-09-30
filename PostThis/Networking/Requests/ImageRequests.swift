//
//  ImageRequests.swift
//  PostThis
//
//  Created by Liam Jones on 16/05/2022.
//

import Foundation
import UIKit



struct UploadImageRequest: RequestProtocol {
  typealias Response = Void
  
  init(imageID: String, imageData: Data) {
    self.imageID = imageID
    self.imageData = imageData
  }
  
  let imageID: String
  let imageData: Data
  
  var method: HttpMethod { return .POST}
  var path: String { return "/images/\(imageID)" }
  var authHeader: String? { return "Bearer \(UserSettings.shared.token?.value ?? "")" }
  var body: Data? { return imageData }
  
  func handle(data: Data) async throws -> Void { }
}

struct DownloadImageRequest: RequestProtocol {
  typealias Response = UIImage
  
  init(imageID: String) {
    self.imageID = imageID
  }
  
  let imageID: String
  
  var method: HttpMethod { return .GET }
  var path: String { return "/images/\(imageID)" }
  var authHeader: String? { return nil }
  var body: Data? { return nil }
  
  func handle(data: Data) async throws -> UIImage {
    guard let image = UIImage(data: data) else {
      throw PostThisError.imageDecodingFailed
    }
    return image
  }
}

struct DeleteImageRequest: RequestProtocol {
  typealias Response = Void
  
  init(imageID: String) {
    self.imageID = imageID
  }
  
  let imageID: String
  
  var method: HttpMethod { return .DELETE }
  var path: String { return "/images/\(imageID)" }
  var authHeader: String? { return "Bearer \(UserSettings.shared.token?.value ?? "")" }
  var body: Data? { return nil }
  
  func handle(data: Data) async throws -> Void { }
}

