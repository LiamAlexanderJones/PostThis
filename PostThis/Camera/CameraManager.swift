//
//  CameraManager.swift
//  PostThis
//
//  Created by Liam Jones on 13/05/2022.
//

import AVFoundation

enum CameraError: Error {
  case deniedAuthorisation, restrictedAuthorisation, unknownAuthorisation, cameraUnavailable, unableToAddInput, createCaptureInput(Error), unableToAddOutput
}

class CameraManager: ObservableObject {
  
  enum Status {
    case unconfigured, configured, unauthorised, failed
  }
  
  @Published var error: CameraError?
  let session = AVCaptureSession()
  private let sessionQueue = DispatchQueue(label: "SessionQueue")
  private let videoOutput = AVCaptureVideoDataOutput()
  private var status = Status.unconfigured

  
  static let shared = CameraManager()
  
  private init() {
    configure()
  }
  
  private func configure() {
    checkPermissions()
    sessionQueue.async {
      self.configureCaptureSession()
    }
  }
  
  private func set(error: CameraError?) {
    DispatchQueue.main.async {
      self.error = error
    }
  }
  
  private func checkPermissions() {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .notDetermined:
      sessionQueue.suspend()
      AVCaptureDevice.requestAccess(for: .video) { authorised in
        if !authorised {
          self.status = .unauthorised
          self.set(error: .deniedAuthorisation)
        }
        self.sessionQueue.resume()
      }
    case .restricted:
      status = .unauthorised
      self.set(error: .restrictedAuthorisation)
    case .denied:
      status = .unauthorised
      self.set(error: .deniedAuthorisation)
    case .authorized:
      break
    @unknown default:
      status = .unauthorised
      self.set(error: .unknownAuthorisation)
    }
  }
  
  private func configureCaptureSession() {
    guard status == .unconfigured else {
      return
    }
    session.beginConfiguration()
    defer { session.commitConfiguration() }
    
    let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    guard let camera = device else {
      set(error: .cameraUnavailable)
      status = .failed
      return
    }
    do {
      let cameraInput = try AVCaptureDeviceInput(device: camera)
      if session.canAddInput(cameraInput) {
        session.addInput(cameraInput)
      } else {
        self.set(error: .unableToAddInput)
        status = .failed
        return
      }
    } catch {
      set(error: .createCaptureInput(error))
      status = .failed
      return
    }
    
    if session.canAddOutput(videoOutput) {
      session.addOutput(videoOutput)
      videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
      let videoConnection = videoOutput.connection(with: .video)
      videoConnection?.videoOrientation = .portrait
    } else {
      set(error: .unableToAddOutput)
      status = .failed
      return
    }
    
    status = .configured
  }
  
  func set(delegate: AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue) {
    sessionQueue.async {
      self.videoOutput.setSampleBufferDelegate(delegate, queue: queue)
    }
  }
  
  func stopSession() {
    sessionQueue.async { [weak self] in
      self?.session.stopRunning()
    }
  }
  
  func startSession() {
    sessionQueue.async { [weak self] in
      self?.session.startRunning()
    }
  }
  
}
