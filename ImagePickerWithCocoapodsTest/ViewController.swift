//
//  ViewController.swift
//  ImagePickerWithCocoapodsTest
//
//  Created by Jean Carlos Antonio Pereira dos Santos on 28/01/19.
//  Copyright © 2019 Jean Carlos Antonio Pereira dos Santos. All rights reserved.
//

import UIKit
import ImagePicker
import FirebaseStorage

class ViewController: UIViewController, ImagePickerDelegate {
  
  
  // MARK: - Outlets
  @IBOutlet weak var imgBackground: UIImageView!
  
  // MARK: - Properties
  var imagePickerController: ImagePickerController!
  var referenceStorage: StorageReference!
  let dateFormatterGet = DateFormatter(formatt: "yyyy-MM-dd_HH:mm:ss")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    referenceStorage = Storage.storage().reference()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  // MARK: - Actions
  @IBAction func loadImage(_ sender: Any) {
    imagePickerController = ImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.imageLimit = 1
    present(imagePickerController, animated: true, completion: nil)
  }
  
  // MARK: - Delegates
  func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) { return }
  
  func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
    imagePickerController.dismiss(animated: true) {
      
      guard let image = images.first, let data = image.pngData() else { return }
      self.imgBackground.image = image
      
      // Upload to Firebase
      let date = self.dateFormatterGet.string(from: Date())
      let walk = "photos/test_" + date + ".png"
      
      // Metadados
      let metadados = StorageMetadata()
      metadados.contentType = "image/png"
      
      // Saving data into server
      self.referenceStorage.child(walk).putData(data, metadata: metadados, completion: { (metadata, error) in
        if let error = error {
          print("Deu erro \(error.localizedDescription)") //TODO
          return
        } else {
          guard let response = metadata, let path = response.path, let downloadURL = URL(string: path)?.absoluteString else { return }
          print(downloadURL)
        }
      })
      
    }
    return
  }
  
  func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
    imagePickerController.dismiss(animated: true, completion: nil)
    return
  }
  
}
