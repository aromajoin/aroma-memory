//
//  CardView.swift
//  MemoryGame
//
//  Created by Daniel Tsirulnikov on 19.3.2016.
//  Copyright © 2016 Daniel Tsirulnikov. All rights reserved.
//

import UIKit.UICollectionViewCell

class CardCVC: UICollectionViewCell {
  
  // MARK: - Properties
  
  @IBOutlet weak var frontImageView: UIImageView!
  @IBOutlet weak var backImageView: UIImageView!
  @IBOutlet weak var tempImageView: UIImageView!
  
  var card:Card? {
    didSet {
      guard let card = card else { return }
      frontImageView.image = card.image
    }
  }
  
  private(set) var shown: Bool = false
  
  // MARK: - Methods
  
  func showCard(show: Bool, temp: Bool, animated: Bool) {
    frontImageView.isHidden = false
    backImageView.isHidden = false
    tempImageView.isHidden = false
    shown = show
    
    if animated {
      if show {
        if (temp) {
          frontImageView.isHidden = true
          UIView.transition(from: backImageView,
                            to: tempImageView,
                            duration: 0.5,
                            options: [.transitionFlipFromRight, .showHideTransitionViews],
                            completion: { (finished: Bool) -> () in
          })
        } else {
          tempImageView.isHidden = true
          UIView.transition(from: backImageView,
                            to: frontImageView,
                            duration: 0.5,
                            options: [.transitionFlipFromRight, .showHideTransitionViews],
                            completion: { (finished: Bool) -> () in
          })
        }
      } else {
        frontImageView.isHidden = true
        UIView.transition(from: tempImageView,
                          to: backImageView,
                          duration: 0.5,
                          options: [.transitionFlipFromRight, .showHideTransitionViews],
                          completion:  { (finished: Bool) -> () in
        })
      }
    } else {
      if show {
        if temp {
          bringSubview(toFront: tempImageView)
          backImageView.isHidden = true
          frontImageView.isHidden = true
        } else {
          bringSubview(toFront: frontImageView)
          backImageView.isHidden = true
          tempImageView.isHidden = true
        }
      } else {
        bringSubview(toFront: backImageView)
        frontImageView.isHidden = true
        tempImageView.isHidden = true
      }
    }
  }
}
