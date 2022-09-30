//
//  FeedView.swift
//  PostThis
//
//  Created by Liam Jones on 10/05/2022.
//

import SwiftUI

struct FeedView: View {

  init(feedType: FeedType, userID: UUID? = nil) {
    if feedType == .comments { print("ALERT: FeedView should never be called with a FeedType of .comments") }
    UITextView.appearance().backgroundColor = .clear
    self.feedType = feedType
    self.userID = userID
  }
  
  @StateObject var postsViewModel = StatementsViewModel<Post>()
  @ObservedObject var settings: UserSettings = .shared
  
  let feedType: FeedType
  let userID: UUID?
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 15) {
        if feedType != .user {
          AddStatementView<Post>(statementsViewModel: postsViewModel, parentPost: nil, feedType: feedType)
            .background(RoundedRectangle(cornerRadius: 15).fill(.white).shadow(color: .black.opacity(0.8), radius: 3, x: 3, y: 3))
        }
        ForEach(postsViewModel.statements) { post in
          PostView(postsViewModel: postsViewModel, post: post, feedType: feedType)
            .background(RoundedRectangle(cornerRadius: 15).fill(.white).shadow(color: .black.opacity(0.8), radius: 3, x: 3, y: 3))
        }
        Button(action: {
          Task {
            await postsViewModel.getNextPage(feedType: feedType, parentID: userID)
            await postsViewModel.getImages()
          }
        }, label: {
          Label(postsViewModel.reachedEnd ? "There are no more posts" : "Load more posts", systemImage: postsViewModel.reachedEnd ? "stop" : "arrow.down")
        })
        .tint(.mint)
        .disabled(postsViewModel.reachedEnd)
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 15).fill(.white).shadow(color: .black.opacity(0.8), radius: 3, x: 3, y: 3))
      }
      .padding(10)
      .background(Color(uiColor: .systemGray5))
    }
    .onChange(of: settings.loggedIn) { loggedIn in
      if loggedIn && feedType == .main {
        Task {
          await postsViewModel.getStatements(feedType: feedType, refreshAll: false)
          await postsViewModel.getImages()
        }
      }
    }
    .onChange(of: settings.selectedTab) { tabValue in
      if settings.loggedIn && tabValue == 0 && feedType == .main
          || settings.loggedIn && tabValue == 1 && feedType == .global {
        Task {
          await postsViewModel.getStatements(feedType: feedType, refreshAll: true)
          await postsViewModel.getImages()
        }
      }
    }
    .onAppear {
      if settings.loggedIn && feedType == .user {
        Task {
          await postsViewModel.getStatements(feedType: feedType, parentID: userID, refreshAll: false)
          await postsViewModel.getImages()
        }
      }
    }

  }
}

struct FeedView_Previews: PreviewProvider {
  static var previews: some View {
    FeedView(feedType: .global)
  }
}
