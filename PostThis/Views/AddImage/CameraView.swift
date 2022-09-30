//
//  CameraView.swift
//  PostThis
//
//  Created by Liam Jones on 13/05/2022.
//

import SwiftUI

struct CameraView: View {
  
  @StateObject private var viewModel = CameraViewModel()
  @State var showNext = false
  @Environment(\.dismiss) private var dismiss
  @Binding var uploadImage: UIImage?
  
  var body: some View {
    ZStack(alignment: .bottom) {
      FrameView(image: viewModel.frame)
        .edgesIgnoringSafeArea(.all)
        .onTapGesture(perform: viewModel.capturePhoto)
    }
    .onAppear(perform: viewModel.startSession)
    .onChange(of: viewModel.capturedImage, perform: { capturedImage in
      if let capturedImage = capturedImage {
        uploadImage = capturedImage
        viewModel.capturedImage = nil //Unnecessary?
        dismiss()
      }
    })
  }
}

struct CameraView_Previews: PreviewProvider {
  static var previews: some View {
    CameraView(uploadImage: .constant(nil))
  }
}
