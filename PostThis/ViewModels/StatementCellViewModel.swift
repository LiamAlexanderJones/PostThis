//
//  StatementCellViewModel.swift
//  PostThis
//
//  Created by Liam Jones on 01/08/2022.
//

import Foundation
import UIKit


class StatementCellViewModel: ObservableObject {
  
  //StatementCellViewModel is responsible for getting reactions for a single statement (as opposed to StatementsViewModel, which is responsible for a list of statements.
  
  @Published var likeReactors: [User.Public] = []
  @Published var upReactors: [User.Public] = []
  @Published var downReactors: [User.Public] = []
  
  func reactorsFor(type: ReactionType) -> [User.Public] {
    switch type {
    case .like:
      return likeReactors
    case .up:
      return upReactors
    case .down:
      return downReactors
    }
  }
  
  func currentUserReacted(type: ReactionType) -> Bool {
    let reactors = reactorsFor(type: type)
    return reactors.map(\.username).contains(UserSettings.shared.username ?? "")
  }
  
  @MainActor func getReactions(for statement: StatementProtocol, isPost: Bool) async {
    guard let statementID = statement.id else {
      UserSettings.shared.error = PostThisError.nilReactionStatementID
      UserSettings.shared.showMainErrorAlert = true
      return
    }
    let client = APIClient()
    let request = GetReactionsRequest(statementID: statementID, isPost: isPost)
    do {
      let reactorData = try await client.makeRequest(request)
      likeReactors = reactorData.likeReactors
      upReactors = reactorData.upReactors
      downReactors = reactorData.downReactors
    } catch {
      //If you delete a post in one feed and switch to the other, getReactions (called by the statementCell) can be called before the post list updates, and get a 404 error. An admittedly hacky solution is to just let this happen. Error handling by each cell isn't terribly useful anyway, because a connection error would be picked up by higher view models. Nevertheless, this catch block remains in case I do want to implement a better solution.

    }
  }
  
  @MainActor func react(to statement: StatementProtocol, isPost: Bool, reactionType: ReactionType) async {
    guard let statementID = statement.id else {
      UserSettings.shared.error = PostThisError.nilReactionStatementID
      UserSettings.shared.showMainErrorAlert = true
      return
    }
    let client = APIClient()
    let request = ReactionRequest(statementID: statementID, isPost: isPost, reactionType: reactionType, hasReaction: currentUserReacted(type: reactionType))
    do {
      try await client.makeRequest(request)
    } catch {
      UserSettings.shared.error = error
      UserSettings.shared.showMainErrorAlert = true
    }
  }

}
