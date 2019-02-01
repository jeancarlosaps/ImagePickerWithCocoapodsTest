//
//  FIRDataObject.swift
//  ImagePickerWithCocoapodsTest
//
//  Created by Jean Carlos Antonio Pereira dos Santos on 01/02/19.
//  Copyright © 2019 Jean Carlos Antonio Pereira dos Santos. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FIRDataObject: NSObject {
  let snapShot: DataSnapshot
  @objc var key: String {return snapShot.key}
  
  required init(snapShot: DataSnapshot){
    self.snapShot = snapShot
    
    super.init()
    
    for child in snapShot.children.allObjects as? [DataSnapshot] ?? [] {
      if responds(to: Selector(child.key)) {
        setValue(child.value, forKey: child.key)
      }
    }
  }
}
