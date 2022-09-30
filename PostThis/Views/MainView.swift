//
//  ContentView.swift
//  PostThis
//
//  Created by Liam Jones on 08/05/2022.
//



import SwiftUI

struct MainView: View {
  
  init() {
    UINavigationBar.appearance().barTintColor = .systemMint
    UINavigationBar.appearance().backgroundColor = .systemMint
  }
  
  @ObservedObject var settings: UserSettings = .shared
  
  var body: some View {
    NavigationView {
      TabView(selection: $settings.selectedTab) {
        FeedView(feedType: .main)
          .tabItem {
            Label("Main Feed", systemImage: "rectangle.grid.1x2")
          }.tag(0)
        FeedView(feedType: .global)
          .tabItem {
            Label("Global Feed", systemImage: "globe")
          }.tag(1)
        ProfileView()
          .tabItem {
            Label("Profile", systemImage: "person.circle")
          }.tag(2)
      }
      .accentColor(.mint)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Label("PostThis", systemImage: "envelope")
            .labelStyle(.titleAndIcon)
            .foregroundColor(.white)
            .font(.system(.largeTitle, design: .serif).bold())
          
        }
      }
    }
    .errorAlert(isPresented: $settings.showMainErrorAlert)
    .fullScreenCover(isPresented: !$settings.loggedIn) {
      LoginView()
    }
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
