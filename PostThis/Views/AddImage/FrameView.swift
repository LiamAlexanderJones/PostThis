//
//  FrameView.swift
//  PostThis
//
//  Created by Liam Jones on 13/05/2022.
//

import SwiftUI

struct FrameView: View {
  
  var image: CGImage?
  private let label = Text("Camera Feed")
  
  var body: some View {
    if let image = image {
      GeometryReader { geo in
        Image(image, scale: 1.0, orientation: .upMirrored, label: label)
          .resizable()
          .scaledToFill()
          .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
          .clipped()
      }
    } else {
      Image(systemName: "exclamationmark.circle")
        .resizable()
        .scaledToFill()
        .frame(width: 300)
      Color.black
      //TODO: Make this better
    }
  }
}

struct FrameView_Previews: PreviewProvider {
  static var previews: some View {
    FrameView()
  }
}
