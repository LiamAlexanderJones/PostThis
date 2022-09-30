//
//  ProfileViewModel.swift
//  PostThis
//
//  Created by Liam Jones on 27/07/2022.
//

import Foundation
import UIKit

class ProfileViewModel: ObservableObject {
  
  @Published var newProfilePic: UIImage?
  
  @MainActor func deleteProfilePic() async {
    guard UserSettings.shared.profilePic != nil else { return }
    let client = APIClient()
    do {
      guard let username = UserSettings.shared.username else { throw PostThisError.userSettingsNil }
      let deleteRequest = DeleteImageRequest(imageID: username)
      try await client.makeRequest(deleteRequest)
      UserSettings.shared.profilePic = nil
      UserSettings.shared.defaultProfilePic = username.makeInitial()
    } catch {
      UserSettings.shared.error = error
      UserSettings.shared.showMainErrorAlert = true
    }
  }
  
  @MainActor func updateProfilePic() async {
    let client = APIClient()
    do {
      guard let username = UserSettings.shared.username else { throw PostThisError.userSettingsNil }
      guard let imageData = newProfilePic?.jpegData(compressionQuality: 60) else { throw PostThisError.imageCompressionFailed }
      if UserSettings.shared.profilePic != nil {
        let deleteRequest = DeleteImageRequest(imageID: username)
        try await client.makeRequest(deleteRequest)
      }
      let uploadRequest = UploadImageRequest(imageID: username, imageData: imageData)
      try await client.makeRequest(uploadRequest)
      let downloadRequest = DownloadImageRequest(imageID: username)
      UserSettings.shared.profilePic = try await client.makeRequest(downloadRequest)
    } catch {
      UserSettings.shared.error = error
      UserSettings.shared.showMainErrorAlert = true
    }
  }

}

