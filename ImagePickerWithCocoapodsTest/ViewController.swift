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
import FirebaseDatabase

class ViewController: UIViewController, ImagePickerDelegate {
  
  
  // MARK: - Outlets
  @IBOutlet weak var imgBackground: UIImageView!
  @IBOutlet weak var appName: UITextField!
  @IBOutlet weak var appPrice: UITextField!
  
  // MARK: - Properties
  var imagePickerController: ImagePickerController!
  var referenceStorage: StorageReference!
  var referenceDatabase: DatabaseReference!
  let dateFormatterGet = DateFormatter(formatt: "yyyy-MM-dd_HH:mm:ss")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    referenceStorage = Storage.storage().reference()
    referenceDatabase = Database.database().reference()
  }
  
  // MARK: - Internal functions
  func showAlerts(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.actionSheet)
    let buttonOk = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
    
    alert.addAction(buttonOk)
    self.present(alert, animated: true, completion: nil)
  }
  // MARK: - Actions
  @IBAction func loadImage(_ sender: Any) {
    imagePickerController = ImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.imageLimit = 1
    present(imagePickerController, animated: true, completion: nil)
  }
  
  @IBAction func uploadData(_ sender: Any) {
    
    guard let nameApp = self.appName.text else {
      showAlerts(title: "Preencha as informações", message: "Preencha corretamenta o nome do aplicativo.")
      return
    }
    
    guard let price = Int(self.appPrice.text!) else {
      showAlerts(title: "Preencha as informações", message: "Preencha corretamenta o preço do aplicativo.")
      return
    }
    
    if nameApp == ""{
      showAlerts(title: "Preencha as informações", message: "Preencha corretamenta o nome do aplicativo.")
      return
    }
    
    guard let image = imgBackground.image, let data = image.pngData() else {
      showAlerts(title: "Preencha as informações", message: "Selecione uma imagem clicando no botão carregar imagem.")
      return
    }
    // Upload to Firebase
    let date = self.dateFormatterGet.string(from: Date())
    let walk = "photos/test_" + date + ".png"
    
    // Metadados
    let metadados = StorageMetadata()
    metadados.contentType = "image/png"
    
    // Saving data into server
    self.referenceStorage.child(walk).putData(data, metadata: metadados, completion: { (metadata, error) in
      if let error = error {
        self.showAlerts(title: "Erro no upload", message: "A imagem não pode ser adicionada no estoragem pq \(error.localizedDescription)")
        return
      } else {
        guard let response = metadata, let path = response.path, let downloadURL = URL(string: path)?.absoluteString else { return }
        
        let folder = self.referenceDatabase.child("apps")
        folder.observeSingleEvent(of: .value, with: { (snapShot) in
          var array = [Dictionary<String, Any>]()
          for item in snapShot.children {
            let appInfo = AppInfo(snapShot: item as! DataSnapshot)
            array.append(appInfo.dictionaryRepresentation)
          }
          
          let newAppInfo = AppInfo(name: nameApp, price: price, imageURL: downloadURL)
          array.append(newAppInfo.dictionaryRepresentation)
          
          folder.setValue(array, withCompletionBlock: { (error, dbRef) in
            if let _ = error {
              self.showAlerts(title: "Erro ao salvar", message: "Os dados não podem ser salvos. Tente novamente.")
            } else {
              self.showAlerts(title: "Salvo com sucesso", message: "A imagem e os dados foram salvos com sucesso!")
            }
          })
        })
      }
    })
  }
  
  // MARK: - Delegates
  func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) { return }
  
  func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
    imagePickerController.dismiss(animated: true) {
      
      guard let image = images.first else { return }
      self.imgBackground.image = image
      
    }
    return
  }
  
  func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
    imagePickerController.dismiss(animated: true, completion: nil)
    return
  }
  
}
