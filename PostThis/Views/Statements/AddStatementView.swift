//
//  AddStatementView.swift
//  PostThis
//
//  Created by Liam Jones on 12/07/2022.
//

import SwiftUI

struct AddStatementView<Statement: StatementProtocol>: View where Statement: Codable {
  
  @ObservedObject var statementsViewModel: StatementsViewModel<Statement>
  @ObservedObject var settings: UserSettings = .shared
  @State var showImageSheet = false
  let parentPost: Post?
  let feedType: FeedType
  let screenSize = UIScreen.main.bounds.size

  var body: some View {
    VStack(alignment: .trailing) {
      HStack {
        Image(uiImage: settings.profilePic ?? settings.defaultProfilePic)
          .resizable()
          .scaledToFill()
          .frame(width: screenSize.width / 5, height: screenSize.width / 5)
          .clipShape(Circle())
          .background(Circle().fill(.white).shadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2))
        VStack {
          if let image = statementsViewModel.newImage {
            VStack(alignment: .trailing) {
              Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: screenSize.width * 3 / 5)
              Button(role: .destructive, action: {
                withAnimation { statementsViewModel.newImage = nil }
              }, label: {
                Image(systemName: "xmark.circle")
              })
            }
          }
          if #available(iOS 16.0, *) {
            Text(statementsViewModel.newCaption).foregroundColor(.clear).padding(8)
              .frame(maxWidth: .infinity, minHeight: screenSize.width / 6)
              .background(
                RoundedRectangle(cornerRadius: 9).fill(Color(uiColor: .systemGray5))
                  .shadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2)
              )
              .overlay(
                TextEditor(text: $statementsViewModel.newCaption)
                  .scrollContentBackground(.hidden)
              )
          } else {
            // Fallback on earlier versions
            Text(statementsViewModel.newCaption).foregroundColor(.clear).padding(8)
              .frame(maxWidth: .infinity, minHeight: screenSize.width / 6)
              .background(
                RoundedRectangle(cornerRadius: 9).fill(Color(uiColor: .systemGray5))
                  .shadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2)
              )
              .overlay(
                TextEditor(text: $statementsViewModel.newCaption)
              )
          }
        }
      }
      .padding(.bottom, 5)
      if statementsViewModel.uploading {
        LoadingView()
          .scaledToFit()
          .frame(height: screenSize.width / 10)
      } else {
        HStack {
          
          Button(action: {
            Task {
              if settings.loggedIn {
                await statementsViewModel.getStatements(feedType: feedType, parentID: parentPost?.id, refreshAll: false)
                await statementsViewModel.getImages()
              }
            }
          }, label: {
            Image(systemName: "arrow.clockwise")
              .font(.body.bold())
          })
          .tint(.mint)
          .buttonStyle(.borderless)
          
          Spacer()
          
          Button(action: { showImageSheet = true }, label: {
            Image(systemName: "photo")
            
          })
          .tint(.mint)
          .buttonStyle(.bordered)
          .buttonBorderShape(.capsule)
          .background(Capsule().fill(.white).shadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2))
          .padding(.horizontal)
          
          Button(action: {
            Task {
              //We could just add a new statement to the array, but this is a good excuse to refresh the feed
              await statementsViewModel.uploadStatement(post: parentPost)
              await statementsViewModel.getStatements(feedType: feedType, parentID: parentPost?.id, refreshAll: false)
              await statementsViewModel.getImages()
            }
          }, label: {
            Text("Post").bold()
          })
          .tint(.mint)
          .buttonStyle(.borderedProminent)
          .buttonBorderShape(.capsule)
          .disabled(statementsViewModel.newCaption.isEmpty)
          .background(Capsule().fill(.white).shadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2))
          .padding(.leading)
          

        }
      }
    }
    .padding()
    .sheet(
      isPresented: $showImageSheet,
      onDismiss: {
        CameraManager.shared.stopSession()
      },content: {
        AddImageView(uploadImage: $statementsViewModel.newImage)
      })
    
  }
}

struct AddStatementView_Previews: PreviewProvider {
    static var previews: some View {
      AddStatementView<Post>(statementsViewModel: StatementsViewModel(), parentPost: nil, feedType: .global)
    }
}
