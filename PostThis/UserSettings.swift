//
//  UserSettings.swift
//  PostThis
//
//  Created by Liam Jones on 11/05/2022.
//

import Foundation
import SwiftUI

class UserSettings: ObservableObject {
  
  private init() { }
  
  static let shared = UserSettings()
  
  @Published var loggedIn: Bool = false
  @Published var selectedTab: Int = 0
  @Published var username: String? = nil
  @Published var profilePic: UIImage? = nil
  @Published var defaultProfilePic = UIImage()
  @Published var token: Token? = nil
  @Published var following: [User.Public] = []
  @Published var profilePicBuffer: [UUID : UIImage] = [:]
  @Published var statementImageBuffer: [UUID : UIImage] = [:]
  
  @Published var error: Error? = nil
  @Published var showLoginErrorAlert: Bool = false
  @Published var showSheetErrorAlert: Bool = false
  @Published var showMainErrorAlert: Bool = false
  
  static let resultsPerPage = 5
  
  
  func logout() {
    token = nil
    defaultProfilePic = UIImage()
    profilePic = nil
    username = nil
    selectedTab = 0
    loggedIn = false
    following = []
    profilePicBuffer = [:]
    statementImageBuffer = [:]
    error = nil
    showLoginErrorAlert = false
    showSheetErrorAlert = false
    showMainErrorAlert = false
  }
  
  @MainActor func getProfilePic() async {
    guard let username = username else { return }
    let client = APIClient()
    let profilePicRequest = DownloadImageRequest(imageID: username)
    do {
      UserSettings.shared.profilePic = try await client.makeRequest(profilePicRequest)
    } catch {
      UserSettings.shared.defaultProfilePic = username.makeInitial()
    }
  }
  
  @MainActor func getFollowing() async {
    let client = APIClient()
    let getFollowingRequest = GetFollowedUsersRequest()
    do {
      UserSettings.shared.following = try await client.makeRequest(getFollowingRequest)
    } catch {
      //GetFollowing is called from LoginView immediately after login. No point in showing an error here if login failed.
      if !showLoginErrorAlert && !showMainErrorAlert {
        self.error = error
        self.showMainErrorAlert = true
      }
    }
  }
  
  @MainActor func follow(user: User.Public) async {
    //We update the local list of followed users manually, which saves making a database search for users every time. (This is different to statements, because other users can add to statement feeds.) The downside is it's possible for the database and client to desynchronise.
    let client = APIClient()
    do {
      guard let id = user.id else { throw PostThisError.nilFollowID }
      let request = FollowRequest(id: id)
      try await client.makeRequest(request)
      if following.contains(user) {
        following.removeAll(where: { $0 == user })
      } else {
        following.append(user)
      }
    } catch {
      self.error = error
      self.showMainErrorAlert = true
    }
  }
  
}

//This extension allows us to present LoginView as a FullScreenCover when loggedIn is false.
prefix func ! (value: Binding<Bool>) -> Binding<Bool> {
  return Binding<Bool>(
    get: { !value.wrappedValue },
    set: { value.wrappedValue = !$0 }
  )
}

extension String {
  func makeInitial() -> UIImage {
    let firstLetter = self.first?.uppercased() ?? "?"
    let foregroundHue = CGFloat(abs(self.hash) % 100) / 100
    let backgroundHue = 1.0 - foregroundHue
    let foregroundColour = UIColor(hue: foregroundHue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
    let backgroundColour = UIColor(hue: backgroundHue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
    let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: foregroundColour, .backgroundColor: UIColor.clear, .font: UIFont.boldSystemFont(ofSize: 40)]
    let size = (firstLetter as NSString).size(withAttributes: attributes)
    let border = CGFloat(8)
    let frameSize = CGSize(width: size.width + 2.0 * border, height: size.height + 2.0 * border)
    
    return UIGraphicsImageRenderer(size: frameSize).image { context in
      backgroundColour.setFill()
      context.fill(CGRect(origin: .zero, size: frameSize))
      (firstLetter as NSString).draw(in: CGRect(origin: CGPoint(x: border, y: border), size: size), withAttributes: attributes)
    }
  }
}




