//
//  LoginView.swift
//  PostThis
//
//  Created by Liam Jones on 10/05/2022.
//

import SwiftUI

struct LoginView: View {
  
  @ObservedObject var settings: UserSettings = .shared
  @StateObject var loginViewModel = LoginViewModel()

  var body: some View {
    VStack {
      Label("PostThis", systemImage: "envelope")
        .labelStyle(.titleAndIcon)
        .foregroundColor(.white)
        .font(.system(.largeTitle, design: .serif).bold())
        .frame(maxWidth: .infinity)
        .padding(.vertical, 5)
        .background(Color.mint)
        .padding(.top)
      Spacer()
      Text(loginViewModel.loginMode ? "Log In" : "Create Account")
        .font(.title)
        .padding()
      VStack(alignment: .trailing, spacing: 20) {
      TextField("Username", text: $loginViewModel.username, prompt: Text("Username"))
        .textContentType(.username)
        .padding(.vertical, 6)
        .padding(.horizontal, 9)
        .background(Capsule().fill(Color(uiColor: .systemGray5)).shadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2))
      if !loginViewModel.loginMode {
        TextField("Email", text: $loginViewModel.email, prompt: Text("Email"))
          .textContentType(.emailAddress)
          .padding(.vertical, 6)
          .padding(.horizontal, 9)
          .background(Capsule().fill(Color(uiColor: .systemGray5)).shadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2))
      }
      SecureField("Password", text: $loginViewModel.password, prompt: Text("Password"))
        .textContentType(.password)
        .padding(.vertical, 6)
        .padding(.horizontal, 9)
        .background(Capsule().fill(Color(uiColor: .systemGray5)).shadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2))
      
        Button(action: {
          Task {
            if loginViewModel.loginMode {
              await loginViewModel.login()
              await settings.getProfilePic()
              await settings.getFollowing()
            } else {
              await loginViewModel.createAccount()
              settings.defaultProfilePic = settings.username?.makeInitial() ?? UIImage()
            }
          }
        }, label: {
          HStack {
            Text(loginViewModel.loginMode ? "Log In" : "Sign Up")
            Image(systemName: "arrow.right.square")
          }
          .font(.title3.bold())
        })
        .disabled(loginViewModel.username.isEmpty || loginViewModel.password.isEmpty)
        .disabled(!loginViewModel.loginMode && loginViewModel.email.isEmpty)
        .tint(.mint)
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .background(Capsule().fill(.white).shadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2))

        Spacer()
        Button("Or \(loginViewModel.loginMode ? "create an account" : "log in")") {
          withAnimation { loginViewModel.loginMode.toggle() }
        }
        .tint(Color.mint.opacity(0.6))
        .buttonStyle(.bordered)
        .buttonBorderShape(.capsule)
        .background(Capsule().fill(.white).shadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2))
        Spacer()
      }
      .padding(.horizontal)
      .frame(maxWidth: .infinity)
    }
    .errorAlert(isPresented: $settings.showLoginErrorAlert)
  }
  

  
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView()
  }
}
