//
//  DateFormatter+extensions.swift
//  ImagePickerWithCocoapodsTest
//
//  Created by Jean Carlos Antonio Pereira dos Santos on 31/01/19.
//  Copyright © 2019 Jean Carlos Antonio Pereira dos Santos. All rights reserved.
//

import UIKit

extension DateFormatter {
  convenience init(formatt: String) {
    self.init()
    self.dateFormat = formatt
  }
}
