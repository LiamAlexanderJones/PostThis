//
//  FrameManager.swift
//  PostThis
//
//  Created by Liam Jones on 13/05/2022.
//

import AVFoundation

class FrameManager: NSObject, ObservableObject {
  
  static let shared = FrameManager()
  @Published var current: CVPixelBuffer?
  let videoOutputQueue = DispatchQueue(label: "VideoOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
  
  private override init() {
    super.init()
    CameraManager.shared.set(delegate: self, queue: videoOutputQueue)
  }
}

extension FrameManager: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    if let buffer = sampleBuffer.imageBuffer {
      DispatchQueue.main.async {
        self.current = buffer
      }
    }
  }
}

