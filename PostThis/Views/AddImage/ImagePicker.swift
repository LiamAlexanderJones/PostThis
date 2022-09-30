//
//  ImagePicker.swift
//  PostThis
//
//  Created by Liam Jones on 05/06/2022.
//

import PhotosUI
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
  typealias UIViewControllerType = PHPickerViewController
  
  @Binding var image: UIImage?
  
  func makeUIViewController(context: Context) -> PHPickerViewController {
    var config = PHPickerConfiguration()
    config.filter = .images
    let picker = PHPickerViewController(configuration: config)
    picker.delegate = context.coordinator
    return picker
  }
  
  func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }
  
  class Coordinator: NSObject, PHPickerViewControllerDelegate {
    let parent: ImagePicker
    init(_ parent: ImagePicker) {
      self.parent = parent
    }
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
      picker.dismiss(animated: true)
      guard let provider = results.first?.itemProvider else { return }
      if provider.canLoadObject(ofClass: UIImage.self) {
        provider.loadObject(ofClass: UIImage.self) { image, error in
          DispatchQueue.main.async {
            self.parent.image = image as? UIImage
          }
        }
      }
    }
  }

}
