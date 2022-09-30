//
//  FeedGeneralViewModel.swift
//  PostThis
//
//  Created by Liam Jones on 12/07/2022.
//

import Foundation


import Foundation
import SwiftUI


class StatementsViewModel<Statement: StatementProtocol>: ObservableObject where Statement: Codable {
  
  @Published var newCaption = ""
  @Published var newImage: UIImage? = nil
  @Published var statements: [Statement] = []
  @Published var reachedEnd: Bool = false
  @Published var uploading = false
  @Published var uploadSuccess = false
  
  
  //if Statementsviewmodel has a get images funbction, it can run through all the statements. First it checks if an image is in the buffer. If not, it downloads the image and assigns it to the buffer. Statements cell just pulls iamges from the buffer.
  
 
  @MainActor func getStatements(feedType: FeedType, parentID: UUID? = nil, refreshAll: Bool = false) async {
    //getStatements handles getting an initial set of statements. The refreshAll bool allows us to to get all the current statements, so we don't suddenly leap to the first page.
    //If refreshing the entire statements list, we round up to the nearest page. This helps ensure that when a user is followed  and the view refreshes, statements at the end aren't pushed off the bottom. It may be that more than one page of posts are added, so we switch reachedEnd to false in all cases.
    var resultsSize = UserSettings.resultsPerPage
    if refreshAll {
      let remainder = (statements.count % UserSettings.resultsPerPage)
      if remainder == 0 {
        resultsSize = max(statements.count, UserSettings.resultsPerPage)
      } else {
        resultsSize = statements.count - remainder + UserSettings.resultsPerPage
      }
    }
    //reachedEnd = false
    
    let client = APIClient()
    do {
      let request = try GetStatementsRequest<Statement>(feedType: feedType, parentID: parentID, page: 1, resultsPerPage: resultsSize)
      statements = try await client.makeRequest(request)
      reachedEnd = statements.count < UserSettings.resultsPerPage
    } catch {
      UserSettings.shared.error = error
      UserSettings.shared.showMainErrorAlert = true
    }
  }
  
  @MainActor func getNextPage(feedType: FeedType, parentID: UUID? = nil) async {
    if reachedEnd { return }
    //A remainder check prevents duplicate results ending up in statements. There may sometimes be remainders when reachedEnd is false because of refreshing the page. If there are, we remove them, then carry on to ask for a full page of results.
    let remainder = statements.count % UserSettings.resultsPerPage
    if remainder != 0 {
      print("ReachedEnd is false but remainder is not zero. The remainder is \(remainder). The statements count is \(statements.count)")
      if feedType == .comments {
        statements.removeFirst(remainder)
      } else {
        statements.removeLast(remainder)
      }
    }
    let page = (statements.count / UserSettings.resultsPerPage) + 1
    let client = APIClient()
    do {
      let request = try GetStatementsRequest<Statement>(feedType: feedType, parentID: parentID, page: page)
      let downloadedStatements = try await client.makeRequest(request)
      reachedEnd = downloadedStatements.count < UserSettings.resultsPerPage
      if feedType == .comments {
        statements.insert(contentsOf: downloadedStatements, at: 0)
      } else {
        statements.append(contentsOf: downloadedStatements)
      }
    } catch {
      UserSettings.shared.error = error
      if feedType == .user {
        UserSettings.shared.showSheetErrorAlert = true
      } else {
        UserSettings.shared.showMainErrorAlert = true
      }
    }
  }
  
  @MainActor func getImages() async {
    let client = APIClient()
    //We use image buffers to minimise bandwidth consumptioon. When lookign for an image, if it isn't in the buffer we either download it or generate a default, then put the result in the buffer. A downside here is that the only way to refresh the images is the clear the buffers and run getImages again.Currently this only happens when logging off and on again, but it could be added to the refresh butten.
    
    //We don't make error alerts here because the for-in loop could produce a string of errors for each image. Failed profile pic requests are routine, so we just generate a default with makeInitial. Failed statement image reuqests display the sfsymbol exclamationmark.circle as a default.
    
    for statement in statements {
      //We only get profile pictures for statements that aren't created by the current user.
      if statement.createdBy.username != UserSettings.shared.username,
         let userID = statement.createdBy.id,
         UserSettings.shared.profilePicBuffer[userID] == nil {
        let profilePic: UIImage
        let profilePicRequest = DownloadImageRequest(imageID: statement.createdBy.username)
        do {
          profilePic = try await client.makeRequest(profilePicRequest)
        } catch {
          profilePic = statement.createdBy.username.makeInitial()
        }
        UserSettings.shared.profilePicBuffer.updateValue(profilePic, forKey: userID)
      }
      
      if statement.hasImage,
         let statementID = statement.id,
         UserSettings.shared.statementImageBuffer[statementID] == nil {
        let statementImage: UIImage
        let imageRequest = DownloadImageRequest(imageID: statementID.uuidString)
        do {
          statementImage = try await client.makeRequest(imageRequest)
        } catch {
          statementImage = UIImage(systemName: "exclamationmark.circle") ?? UIImage()
        }
        UserSettings.shared.statementImageBuffer.updateValue(statementImage, forKey: statementID)
      }
    }
  }

  @MainActor func uploadStatement(post: Post? = nil) async {
    guard !newCaption.isEmpty else { return }
    self.uploading = true
    
    let client = APIClient()
    let request = UploadNewStatementRequest<Statement>(caption: newCaption, hasImage: newImage != nil, to: post?.id)
    do {
      let uploadedStatementID = try await client.makeRequest(request)
      if let image = newImage {
        guard let imageData = image.jpegData(compressionQuality: 60) else { throw PostThisError.imageCompressionFailed }
        let imgRequest = UploadImageRequest(imageID: uploadedStatementID, imageData: imageData)
        try await client.makeRequest(imgRequest)
      }
      uploadSuccess = true
      newCaption = ""
      newImage = nil
    } catch {
      UserSettings.shared.error = error
      UserSettings.shared.showMainErrorAlert = true
    }
    uploading = false
  }
  
  @MainActor func deleteStatement(statement: StatementProtocol) async {
    guard let statementID = statement.id else { return }
    let client = APIClient()
    let request = DeleteStatementRequest(statementID: statementID, isPost: (statement is Post))
    do {
      try await client.makeRequest(request)
      if statement.hasImage {
        let imgRequest = DeleteImageRequest(imageID: statementID.uuidString)
        try await client.makeRequest(imgRequest)
        UserSettings.shared.statementImageBuffer.removeValue(forKey: statementID)
      }
    } catch {
      UserSettings.shared.error = error
      UserSettings.shared.showMainErrorAlert = true
    }
  }


}



