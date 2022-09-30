//
//  PostView.swift
//  PostThis
//
//  Created by Liam Jones on 18/05/2022.
//

import SwiftUI

struct PostView: View {
  //PostView works with the recursive symmetry of Statement. It displays a single Post using StatementCell, then offers a list of Comments, each with a Statement cell, and an AddStatementView to add a new comment.

  @ObservedObject var postsViewModel: StatementsViewModel<Post>
  @StateObject var commentsViewModel = StatementsViewModel<Comment>()
  @State var showComments: Bool = false
  let screenSize = UIScreen.main.bounds.size
  let post: Post
  let feedType: FeedType
  
  var body: some View {
    VStack(alignment: .leading) {
      StatementCell<Post>(isPost: true, statement: post, parentPost: nil, feedType: feedType, parentViewModel: postsViewModel)
        .padding(.bottom, 2)
      Button(action: {
        withAnimation { showComments.toggle() }
      }, label: {
        Label(showComments ? "Hide Comments" : "Comment", systemImage: showComments ? "arrow.up.backward" : "bubble.left.fill")
      })
      .tint(.mint)
      
      if showComments {
        VStack(alignment: .leading) {
          if !commentsViewModel.reachedEnd && commentsViewModel.statements.count >= UserSettings.resultsPerPage {
            Divider()
            Button("View earlier comments ...") {
              Task {
                if !commentsViewModel.reachedEnd {
                  await commentsViewModel.getNextPage(feedType: .comments, parentID: post.id)
                  await commentsViewModel.getImages()
                }
              }
            }
            .tint(.mint)
            .font(.caption)
          }
          ForEach(commentsViewModel.statements) { comment in
            Divider()
            StatementCell<Comment>(isPost: false, statement: comment, parentPost: post, feedType: .comments, parentViewModel: commentsViewModel)
          }
          Divider()
          AddStatementView<Comment>(statementsViewModel: commentsViewModel, parentPost: post, feedType: .comments)
        }
        .padding(.horizontal, 15)
        .task {
          await commentsViewModel.getStatements(feedType: .comments, parentID: post.id, refreshAll: false)
          await commentsViewModel.getImages()
        }
      }
    }
    .padding()
  }
}

struct PostView_Previews: PreviewProvider {
  static var previews: some View {
    let post = Post(body: "Body text", createdAt: Date(), username: "Person", hasImage: false)
    return PostView(postsViewModel: StatementsViewModel(), post: post, feedType: .global)
  }
}
