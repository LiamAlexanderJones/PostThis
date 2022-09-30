//
//  TakePhotoView.swift
//  PostThis
//
//  Created by Liam Jones on 19/05/2022.
//

import SwiftUI

struct AddImageView: View {
  @Binding var uploadImage: UIImage?
  @ObservedObject var settings = UserSettings.shared
  
  var body: some View {
    NavigationView {
      
      HStack(spacing: 20) {
//        NavigationLink(destination: CameraView(uploadImage: $uploadImage)) {
//          VStack {
//            Image(systemName: "camera.circle.fill")
//              .resizable()
//              .scaledToFit()
//              .foregroundColor(.white)
//              .padding()
//            Text("From camera").bold()
//              .foregroundColor(.white)
//              .padding()
//          }
//          .frame(width: UIScreen.main.bounds.size.width * 0.4, height: UIScreen.main.bounds.size.width * 0.64)
//          .background(RoundedRectangle(cornerRadius: 20).fill(.mint).shadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2))
//        }
        NavigationLink(destination: ImagePicker(image: $uploadImage)) {
          VStack {
            Image(systemName: "photo.on.rectangle.fill")
              .resizable()
              .scaledToFit()
              .foregroundColor(.white)
              .padding()
            Text("From gallery").bold()
              .foregroundColor(.white)
              .padding()
          }
          .frame(width: UIScreen.main.bounds.size.width * 0.4, height: UIScreen.main.bounds.size.width * 0.64)
          .background(RoundedRectangle(cornerRadius: 20).fill(.mint).shadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2))
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("Add Image")
            .foregroundColor(.white)
            .font(.system(.largeTitle, design: .serif).bold())
        }
      }
    }
    .errorAlert(isPresented: $settings.showSheetErrorAlert)
  }
}

struct AddImageView_Previews: PreviewProvider {
  static var previews: some View {
    AddImageView(uploadImage: .constant(nil))
  }
}
