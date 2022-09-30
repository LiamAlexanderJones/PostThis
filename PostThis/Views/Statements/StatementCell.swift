//
//  PostView.swift
//  PostThis
//
//  Created by Liam Jones on 10/05/2022.
//

import SwiftUI


struct StatementCell<Statement: StatementProtocol>: View where Statement: Codable {
  //We use a single view for posts and comments with a bool to differentiate with them. Because they layout is substantially the same but fonts and sizes aren't, viewbuilder seems less suitable.
  
  let isPost: Bool
  let statement: Statement
  let parentPost: Post?
  let feedType: FeedType
  let screenSize = UIScreen.main.bounds.size
  @ObservedObject var parentViewModel: StatementsViewModel<Statement>
  @ObservedObject var settings: UserSettings = .shared
  @StateObject var cellViewModel = StatementCellViewModel()
  @State var showReactorsByType: ReactionType? = nil
  @State var showErrorView: Bool = false
  @State private var showProfileFor: User.Public? = nil
  @State private var showConfirmation: Bool = false
  var reactorOffset: CGFloat {
    switch showReactorsByType {
    case .up: return 70
    case .down: return 140
    default: return 0
    }
  }
  let formatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.dateTimeStyle = .named
    formatter.unitsStyle = .short
    return formatter
  }()
  
  var body: some View {
    //MARK: Header
    VStack(alignment: .leading) {
      HStack {
        Image(uiImage: statement.createdBy.username == settings.username
              ? (settings.profilePic ?? settings.defaultProfilePic)
              : settings.profilePicBuffer[statement.createdBy.id ?? UUID()] ?? UIImage() )
          .resizable()
          .scaledToFill()
          .frame(width: screenSize.width / (isPost ? 5 : 7), height: screenSize.width / (isPost ? 5 : 7))
          .clipShape(Circle())
          .background(Circle().fill(.white).shadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2))
        VStack(alignment: .leading) {
          Menu(content: {
            if statement.createdBy.username != UserSettings.shared.username {
              Button(settings.following.contains(statement.createdBy) ? "Unfollow" : "Follow") {
                Task {
                  await settings.follow(user: statement.createdBy)
                  if feedType == .main {
                    await parentViewModel.getStatements(feedType: feedType, refreshAll: true)
                  }
                }
              }
              if feedType != .user { Button("View Profile") { showProfileFor = statement.createdBy } }
            }
          }, label: {
            Text(statement.createdBy.username)
              .font(isPost ? .headline : .subheadline)
              .foregroundColor(.black)
              .bold()
          })
          Text(formatter.localizedString(for: statement.createdAt, relativeTo: Date()))
            .font(isPost ? .subheadline : .caption)
            .foregroundColor(.gray)
        }
        Spacer()
        if statement.createdBy.username == settings.username {
          Button(role: .destructive, action: { showConfirmation = true }, label: {
            Image(systemName: "trash")
          })
          .confirmationDialog("Are you sure you want to delete this \(isPost ? "post" : "comment")?", isPresented: $showConfirmation, titleVisibility: .visible, actions: {
            Button("Delete", role: .destructive, action: {
              Task {
                await parentViewModel.deleteStatement(statement: statement)
                await parentViewModel.getStatements(feedType: feedType, parentID: parentPost?.id, refreshAll: true)
              }
            })
          })
        }
      }
      
      //MARK: Body
      if statement.hasImage {
        Image(uiImage: settings.statementImageBuffer[statement.id ?? UUID()] ?? UIImage())
          .resizable()
          .scaledToFit()
      }
      Text(statement.body)
        .font((!statement.hasImage && isPost) ? .body : .footnote)
        .padding(.bottom, 2)
      
      //MARK: Reactions
      if isPost { Divider() }
      HStack {
        ForEach(ReactionType.allCases, id: \.rawValue) { reactionType in
          Button(action: {
            Task {
              await cellViewModel.react(to: statement, isPost: isPost, reactionType: reactionType)
              await cellViewModel.getReactions(for: statement, isPost: isPost)
            }
          }, label: {
            Image(systemName: cellViewModel.currentUserReacted(type: reactionType)
                  ? reactionType.imageString() + ".fill"
                  : reactionType.imageString()
            )
            .foregroundColor(Color.mint)
          })
          Button(action: {
            withAnimation {
              if reactionType == showReactorsByType {
                showReactorsByType = nil
              } else {
                showReactorsByType = reactionType
              }
            }
          }, label: {
            Text("\(cellViewModel.reactorsFor(type: reactionType).count)")
              .foregroundColor(.black)
              .padding(.horizontal, 5)
              .background(
                RoundedRectangle(cornerRadius: 5).fill(Color.mint.opacity(reactionType == showReactorsByType ? 0.25 : 0.1))
              )
          })
          .padding(.trailing, 15)
        }
      }
      if let type = showReactorsByType, !cellViewModel.reactorsFor(type: type).isEmpty {
        VStack(alignment: .leading) {
          Spacer().frame(height: 5)
          ForEach(cellViewModel.reactorsFor(type: type)) { reactor in
            Menu(content: {
              if reactor.username != UserSettings.shared.username {
                Button(settings.following.contains(reactor) ? "Unfollow" : "Follow") {
                  Task {
                    await settings.follow(user: reactor)
                    if feedType == .main {
                      await parentViewModel.getStatements(feedType: feedType, refreshAll: true)
                    }
                  }
                }
                if !(feedType == .user && reactor == statement.createdBy) {
                  Button("View Profile") { showProfileFor = reactor }
                }
              }
            }, label: {
              Text(reactor.username).foregroundColor(.black)
            })
          }
          Spacer().frame(height: 5)
        }
        .padding(.horizontal, 5)
        .background(RoundedRectangle(cornerRadius: 10).fill(.mint.opacity(0.25)))
        .offset(x: reactorOffset, y: 0)
      }
    }
    .sheet(item: $showProfileFor, content: { user in
      FeedView(feedType: .user, userID: user.id)
    })
    .task(priority: .low) {
        await cellViewModel.getReactions(for: statement, isPost: isPost)
    }
    
  }
}




struct PostOrCommentView_Previews: PreviewProvider {
  static var previews: some View {
    let post = Post(body: "Body text", createdAt: Date(), username: "Person", hasImage: false)
    return StatementCell<Post>(isPost: true, statement: post, parentPost: nil, feedType: .global, parentViewModel: StatementsViewModel<Post>())
  }
}
