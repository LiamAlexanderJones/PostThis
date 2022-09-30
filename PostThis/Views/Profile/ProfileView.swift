//
//  ProfileView.swift
//  PostThis
//
//  Created by Liam Jones on 26/07/2022.
//

import SwiftUI

struct ProfileView: View {
  
  @StateObject var profileViewModel = ProfileViewModel()
  @ObservedObject var settings: UserSettings = .shared
  @State var showImageSheet: Bool = false
  @State var showFollowedUsersSheet: Bool = false
  let screenSize = UIScreen.main.bounds.size
  
  var body: some View {
    VStack {
      VStack {
        Menu(content: {
          Button("Change profile picture") {
            showImageSheet = true
          }
          Button("Delete profile picture") {
            Task {
              await profileViewModel.deleteProfilePic()
            }
          }
        }, label: {
          Image(uiImage: settings.profilePic ?? settings.defaultProfilePic)
            .resizable()
            .scaledToFill()
            .frame(width: screenSize.width / 2, height: screenSize.width / 2)
            .clipShape(Circle())
            .background(Circle().fill(.white).shadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2))
        })

        Text(settings.username ?? "")
          .font(.largeTitle)
      }
      .sheet(
        isPresented: $showImageSheet,
        onDismiss: {
          CameraManager.shared.stopSession()
        },content: {
          AddImageView(uploadImage: $profileViewModel.newProfilePic)
        })
      Divider()
      
      if let profilePic = profileViewModel.newProfilePic {
        Text("New Profile Picture")
        HStack {
          Button(action: {
            withAnimation { profileViewModel.newProfilePic = nil }
          }, label: {
            Image(systemName: "xmark.circle")
              .resizable()
              .scaledToFit()
              .foregroundColor(.red)
              .frame(width: screenSize.width / 8, height: screenSize.width / 8)
          })
          Image(uiImage: profilePic)
            .resizable()
            .scaledToFill()
            .frame(width: screenSize.width / 4, height: screenSize.width / 4)
            .clipShape(Circle())
            .background(Circle().fill(.white).shadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2))
          Button(action: {
            Task {
              await profileViewModel.updateProfilePic()
              withAnimation { profileViewModel.newProfilePic = nil }
            }
          }, label: {
            Image(systemName: "checkmark.circle")
              .resizable()
              .scaledToFit()
              .foregroundColor(.green)
              .frame(width: screenSize.width / 8, height: screenSize.width / 8)
          })
        }
        Divider()
      }
      
      Button("Followed Users") {
        showFollowedUsersSheet = true
      }
      .sheet(isPresented: $showFollowedUsersSheet, content: {
        FollowedUsersView()
      })

      Button("Logout", action: settings.logout)
      Spacer()
    }
    .padding()
  }
  
}

struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    ProfileView()
  }
}
