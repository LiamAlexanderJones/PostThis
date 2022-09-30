//
//  FollowedUsersView.swift
//  PostThis
//
//  Created by Liam Jones on 13/08/2022.
//

import SwiftUI

struct FollowedUsersView: View {
  
  let screenSize = UIScreen.main.bounds.size
  @ObservedObject var settings: UserSettings = .shared
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading) {
          ForEach(UserSettings.shared.following) { followedUser in
            HStack {
              Image(uiImage: settings.profilePicBuffer[followedUser.id ?? UUID()] ?? UIImage())
                .resizable()
                .scaledToFill()
                .frame(width: screenSize.width / 6, height: screenSize.width / 6)
                .clipShape(Circle())
              Text(followedUser.username)
                .font(.title3)
                .foregroundColor(.black)
                .bold()
              Spacer()
              VStack(alignment: .trailing) {
                NavigationLink("See posts", destination: FeedView(feedType: .user, userID: followedUser.id))
                Button("Unfollow") {
                  Task {
                    await settings.follow(user: followedUser)
                  }
                }
              }
            }
            Divider()
          }
        }
        .padding()
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Label("PostThis", systemImage: "envelope")
            .labelStyle(.titleAndIcon)
            .foregroundColor(.white)
            .font(.system(.largeTitle, design: .serif).bold())

        }
      }
    }
    .task {
      let client = APIClient()
      for followedUser in settings.following {
        if let id = followedUser.id,
           settings.profilePicBuffer[id] == nil {
          let request = DownloadImageRequest(imageID: followedUser.username)
          do {
            try await settings.profilePicBuffer[id] = client.makeRequest(request)
          } catch {
            settings.profilePicBuffer[id] = followedUser.username.makeInitial()
          }
        }
      }
    }
    .errorAlert(isPresented: $settings.showSheetErrorAlert)
  }
}

struct FollowedUsersView_Previews: PreviewProvider {
    static var previews: some View {
        FollowedUsersView()
    }
}
