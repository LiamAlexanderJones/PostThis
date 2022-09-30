//
//  LoginViewModel.swift
//  PostThis
//
//  Created by Liam Jones on 18/07/2022.
//

import Foundation

//TODO: on Error fixing

class LoginViewModel: ObservableObject {
  
  @Published var username = ""
  @Published var email = ""
  @Published var password = ""
  @Published var loginMode = true
  
  @MainActor func login() async {
    guard !username.isEmpty, !password.isEmpty else {
      UserSettings.shared.error = PostThisError.fieldsEmpty
      UserSettings.shared.showLoginErrorAlert = true
      return
    }
    let client = APIClient()
    let request = UserLoginRequest(username: username, password: password)
    do {
      try await client.makeRequest(request)
    } catch {
      UserSettings.shared.error = error
      UserSettings.shared.showLoginErrorAlert = true
    }
  }
  
  @MainActor func createAccount() async {
    guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
      UserSettings.shared.error = PostThisError.fieldsEmpty
      UserSettings.shared.showLoginErrorAlert = true
      return
    }
    let client = APIClient()
    //TODO: Add confirm password field
    let request = UserCreateAccountRequest(username: username, password: password, confirmPassword: password)
    do {
      try await client.makeRequest(request)
    } catch {
      UserSettings.shared.error = error
      UserSettings.shared.showLoginErrorAlert = true
    }
  }
  
}
