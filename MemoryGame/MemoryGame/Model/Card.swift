//
//  Card.swift
//  MemoryGame
//
//  Created by Daniel Tsirulnikov on 19.3.2016.
//  Copyright © 2016 Daniel Tsirulnikov. All rights reserved.
//

import Foundation
import UIKit.UIImage

class Card : CustomStringConvertible {
  
  // MARK: - Properties
  
  var id:NSUUID = NSUUID.init()
  var shown:Bool = false
  var image:UIImage
  var aromaNumber:Int // 1 ~ 6
  
  // MARK: - Lifecycle
  
  init(image:UIImage, aromaNumber: Int) {
    self.image = image
    self.aromaNumber = aromaNumber
  }
  
  init(card:Card) {
    self.id = card.id.copy() as! NSUUID
    self.shown = card.shown
    self.image = card.image.copy() as! UIImage
    self.aromaNumber = card.aromaNumber
  }
  
  // MARK: - Methods
  
  var description: String {
    return "\(id.uuidString)"
  }
  
  func equals(card: Card) -> Bool {
    return card.id.isEqual(id)
  }
}
