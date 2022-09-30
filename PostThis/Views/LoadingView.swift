//
//  LoadingView.swift
//  PostThis
//
//  Created by Liam Jones on 27/05/2022.
//

import SwiftUI

struct LoadingView: View {
  
  @State var currentIndex = -1
  let segmentCount = 8
  
  var body: some View {
    ZStack {
      ForEach(0..<segmentCount) { index in
        Rectangle()
          .fill(.mint)
          .frame(width: 20, height: 2)
          .rotationEffect(currentIndex == index ? .radians(.pi) : .radians(0))
          .offset(.init(width: 0, height: 25))
          .rotationEffect(.init(radians: .pi * 2 * Double(index) / Double(segmentCount)))
          .animation(.easeInOut(duration: 0.5), value: currentIndex)
      }
    }
    .onAppear(perform: animate)
  }
  
  func animate() {
    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
      currentIndex = (currentIndex + 1) % segmentCount
    }
  }
  
}

struct LoadingView_Previews: PreviewProvider {
  static var previews: some View {
    LoadingView()
  }
}
