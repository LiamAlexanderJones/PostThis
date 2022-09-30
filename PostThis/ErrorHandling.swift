//
//  ErrorHandling.swift
//  PostThis
//
//  Created by Liam Jones on 25/08/2022.
//

import Foundation
import SwiftUI



enum PostThisError: Error {
  case networkError(Int)
  case decodingError
  case uploadIDFailed
  case imageCompressionFailed
  case nilParentPostID
  case nilParentUserID
  case nilCreatedByID
  case nilFollowID
  case nilReactionStatementID
  case imageDecodingFailed
  case fieldsEmpty
  case userSettingsNil
  
  var errorDescription: String {
    switch self {
    case .networkError(let statusCode):
      switch statusCode {
      case 404:
        return "Connection error: 404 not found"
      case 401:
        return "Connection error: Authorisation needed"
      default:
        return "There was a problem connecting to the network. The status code is \(statusCode)"
      }
    case .decodingError:
      return "There was a problem decoding"
    case .uploadIDFailed:
      return "Failed to get an ID for the uploaded statement"
    case .imageCompressionFailed:
      return "Image compression failed"
    case .nilParentPostID:
      return "The app tried to get comments with a nil post ID"
    case .nilParentUserID:
      return "The app tried to get user posts with a nil user ID"
    case .nilCreatedByID:
      return "The app tried to get an image, but found a nil ID in createdBy"
    case .nilFollowID:
      return "The app tried to follow a user but found a nil ID"
    case .nilReactionStatementID:
      return "The app tried to get reactions or react to a statement but found a nil ID"
    case .imageDecodingFailed:
      return "The app couldn't decode an image from the data provided by the server"
    case .fieldsEmpty:
      return "The login/sign up fields are empty"
    case .userSettingsNil:
      return "The app found a nil value in the user settings. Try logging out and logging in"
    }
  }
  
}

extension View {
  func errorAlert(isPresented: Binding<Bool>) -> some View {
    return alert("Something went wrong", isPresented: isPresented, actions: {
      Button("OK") { }
    }, message: {
      if let ptError = UserSettings.shared.error as? PostThisError {
        Text(ptError.errorDescription)
      } else if let localizedError = UserSettings.shared.error as? LocalizedError {
        Text("Error description: \(localizedError.errorDescription ?? "Unknown"). Failure reason: \(localizedError.failureReason ?? "Unknown"). Recovery suggestion: \(localizedError.recoverySuggestion ?? "Unknown")")
      } else {
        Text(UserSettings.shared.error?.localizedDescription ?? "???")
      }
    })
  }
}


