//
//  PostThisTests.swift
//  PostThisTests
//
//  Created by Liam Jones on 08/05/2022.
//

import XCTest
@testable import PostThis

class RequestTests: XCTestCase {
  
  func test_getPostsHandleWithGoodData() async {
    //Given
    let posts = [Post(body: "body", hasImage: false), Post(body: "body2", hasImage: false), Post(body: "body3", hasImage: false)]
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let jsonData = try! encoder.encode(posts)
    print(String(data: jsonData, encoding: .utf8)!)
    //When
    do {
      let postsRequest = try GetStatementsRequest<Post>(feedType: .global)
      let posts = try await postsRequest.handle(data: jsonData)
      //Then
      XCTAssertEqual(posts.count, 3)
    } catch {
      XCTFail( (error.localizedDescription) )
    }
  }
  
  func test_getPostsHandleWithBadData() async throws {
    //Given
    let data = "not json".data(using: .utf8)!
    let postsRequest = try GetStatementsRequest<Post>(feedType: .global)
    //When
    do {
      let _ = try await postsRequest.handle(data: data)
      //Then
      XCTFail("Should throw")
    } catch {
      switch error {
      case PostThisError.decodingError:
        break
      default:
        XCTFail()
      }
    }
  }
  
  func test_uploadPostHandle() async {
    //Given
    let string = "Test string"
    let data = string.data(using: .ascii)!
    let uploadPostRequest = UploadNewStatementRequest<Post>(caption: "", hasImage: false)
    //When
    do {
      let returnedString = try await uploadPostRequest.handle(data: data)
      //Then
      XCTAssertEqual(returnedString, string)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  



}
