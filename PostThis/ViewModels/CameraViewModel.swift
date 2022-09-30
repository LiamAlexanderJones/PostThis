//
//  CameraViewModel.swift
//  PostThis
//
//  Created by Liam Jones on 13/05/2022.
//

import CoreImage
import Combine
import UIKit

class CameraViewModel: ObservableObject {
  
  @Published var capturedImage: UIImage?
  @Published var frame: CGImage?
  
  private let cameraManager = CameraManager.shared
  private let frameManager = FrameManager.shared
  private let context = CIContext()
  private var subscriptions: Set<AnyCancellable> = []
  
  init() {
    setupSubscriptions()
  }
  
  func setupSubscriptions() {
    
    cameraManager.$error
      .receive(on: RunLoop.main)
      .map { $0 }
      .sink(receiveValue: { err in
        if let err = err {
          UserSettings.shared.error = err
          UserSettings.shared.showSheetErrorAlert = true
        }
      })
      .store(in: &subscriptions)
    
    frameManager.$current
      .receive(on: RunLoop.main)
      .compactMap { $0 }
      .compactMap { buffer in
        let ciImage = CIImage(cvImageBuffer: buffer)
        //TODO: Option to apply filters here
        return self.context.createCGImage(ciImage, from: ciImage.extent)
      }
      .assign(to: &$frame)
  }
  
  //There are two possible ways to get a photo. One is to go through AVFoundation's capturePhoto process. The other is to nab the image directly from the stream in the combine pipeline. Given the current setup, the latter is probably easier. It does, however, require stopping and starting the Combine stream. ANd it may introduce possible difficulties with image capture settings.
  
  func capturePhoto() {
    if let frame = frame {
      capturedImage = UIImage(cgImage: frame)
      cameraManager.stopSession()
    }
  }
  
  func startSession() {
    cameraManager.startSession()
  }
  
}
