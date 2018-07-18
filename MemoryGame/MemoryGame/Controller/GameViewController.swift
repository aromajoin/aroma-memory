//
//  GameViewController.swift
//  MemoryGame
//
//  Created by Daniel Tsirulnikov on 19.3.2016.
//  Copyright © 2016 Daniel Tsirulnikov. All rights reserved.
//

import UIKit
import AromaShooterControllerSwift

class GameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MemoryGameDelegate {
  
  // MARK: Properties
  
  let AROMA_DIFFUSE_DURATION = 2000
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var timerLabel: UILabel!
  @IBOutlet weak var playButton: UIButton!
  @IBOutlet weak var connectButton: UIButton!
  
  let gameController = MemoryGame()
  var timer:Timer?
  
  let asController = AromaShooterController.sharedInstance
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    gameController.delegate = self
    resetGame()
  }
  
  func setPlayButtonAnimation(animated: Bool) {
    if animated {
      UIView.animate(withDuration: 0.8, delay: 0, options: [.repeat, .allowUserInteraction], animations: {
        self.playButton.transform = CGAffineTransform(rotationAngle: -.pi/4)
      }, completion: { _ in
        UIView.animate(withDuration: 0.8) {
          self.playButton.transform = CGAffineTransform.identity
        }
      })
    } else {
      playButton.layer.removeAllAnimations()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if asController.connectedDevices.count == 0 {
      connectButton.setTitle("No connection", for: .normal)
    } else {
      connectButton.setTitle("Connected(\(asController.connectedDevices.count))", for: .normal)
    }
    // Animation for 'Play' button
    setPlayButtonAnimation(animated: true)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    if gameController.isPlaying {
      resetGame()
    }
  }
  
  // MARK: - Methods
  
  func resetGame() {
    gameController.stopGame()
    if timer?.isValid == true {
      timer?.invalidate()
      timer = nil
    }
    collectionView.isUserInteractionEnabled = false
    collectionView.reloadData()
    timerLabel.text = String(format: "%@: ---", NSLocalizedString("TIME", comment: "time"))
    playButton.setTitle(NSLocalizedString("Play", comment: "play"), for: .normal)
  }
  
  @IBAction func didPressPlayButton(_ sender: UIButton) {
    if gameController.isPlaying {
      resetGame()
      playButton.setTitle(NSLocalizedString("PLAY", comment: "play"), for: .normal)
      setPlayButtonAnimation(animated: true)
    } else {
      setupNewGame()
      playButton.setTitle(NSLocalizedString("STOP", comment: "stop"), for: .normal)
      setPlayButtonAnimation(animated: false)
    }
  }
  
  func setupNewGame() {
    let cardsData:[UIImage] = MemoryGame.defaultCardImages
    gameController.newGame(cardsData: cardsData)
  }
  
  @objc func gameTimerAction() {
    timerLabel.text = String(format: "%@: %.0fs", NSLocalizedString("TIME", comment: "time"), gameController.elapsedTime)
  }
  
  func savePlayerScore(name: String, score: TimeInterval) {
    Highscores.sharedInstance.saveHighscore(name: name, score: score)
  }
  
  // MARK: - UICollectionViewDataSource
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return gameController.numberOfCards > 0 ? gameController.numberOfCards : 12
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cardCell", for: indexPath as IndexPath) as! CardCVC
    cell.showCard(show: false, temp: false, animated: false)
    
    guard let card = gameController.cardAtIndex(index: indexPath.item) else { return cell }
    cell.card = card
    
    return cell
  }
  
  // MARK: UICollectionViewDelegate
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! CardCVC
    
    if cell.shown { return }
    gameController.didSelectCard(card: cell.card)
    
    let cartridgeNumber = cell.card?.aromaNumber
    if cartridgeNumber != nil{
      asController.diffuseAll(duration: AROMA_DIFFUSE_DURATION, booster: true, ports: [cartridgeNumber!])
    }
    
    collectionView.deselectItem(at: indexPath as IndexPath, animated:true)
  }
  
  // MARK: - UICollectionViewDataSource
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //let numberOfColumns:Int = self.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
    
    let itemWidth: CGFloat = collectionView.frame.width / 4.0 - 25.0 //numberOfColumns as CGFloat - 10 //- (minimumInteritemSpacing * numberOfColumns))
    
    return CGSize(width: itemWidth, height: itemWidth)
  }
  
  // MARK: - MemoryGameDelegate
  
  func memoryGameDidStart(game: MemoryGame) {
    collectionView.reloadData()
    collectionView.isUserInteractionEnabled = true
    
    timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(gameTimerAction), userInfo: nil, repeats: true)
  }
  
  func memoryGame(game: MemoryGame, showTempCards cards: [Card]) {
    for card in cards {
      guard let index = gameController.indexForCard(card: card) else { continue }
      let cell = collectionView.cellForItem(at: NSIndexPath(item: index, section:0) as IndexPath) as! CardCVC
      cell.showCard(show: true, temp: true, animated: true)
    }
  }
  
  func memoryGame(game: MemoryGame, showCards cards: [Card]) {
    for card in cards {
      guard let index = gameController.indexForCard(card: card) else { continue }
      let cell = collectionView.cellForItem(at: NSIndexPath(item: index, section:0) as IndexPath) as! CardCVC
      cell.showCard(show: true, temp: false, animated: true)
    }
  }
  
  func memoryGame(game: MemoryGame, hideCards cards: [Card]) {
    for card in cards {
      guard let index = gameController.indexForCard(card: card) else { continue }
      let cell = collectionView.cellForItem(at: NSIndexPath(item: index, section:0) as IndexPath) as! CardCVC
      cell.showCard(show: false, temp: false, animated: true)
    }
  }
  
  
  func memoryGameDidEnd(game: MemoryGame, elapsedTime: TimeInterval) {
    timer?.invalidate()
    
    let titleAttributed = NSMutableAttributedString(
      string: "Congrats",
      attributes: [NSAttributedStringKey.font:UIFont(name:"chalkduster",size: 22)]
    )
    
    let messageAttributed = NSMutableAttributedString(
      string: String(format: "%@ %.0f seconds", NSLocalizedString("You finished the game in", comment: "message"), elapsedTime),
      attributes: [NSAttributedStringKey.font:UIFont(name:"chalkduster",size: 17)]
    )
    
    let elapsedTime = gameController.elapsedTime
    
    let alertController = UIAlertController(
      title: "",
      message: "",
      preferredStyle: .alert)
    alertController.setValue(titleAttributed, forKey: "attributedTitle")
    alertController.setValue(messageAttributed, forKey: "attributedMessage")
    
    let saveScoreAction = UIAlertAction(title: NSLocalizedString("Save Score", comment: "save score"), style: .default) { [weak self] (_) in
      let nameTextField = alertController.textFields![0] as UITextField
      guard let name = nameTextField.text else { return }
      self?.savePlayerScore(name: name, score: elapsedTime)
      self?.resetGame()
    }
    
    saveScoreAction.isEnabled = false
    alertController.addAction(saveScoreAction)
    
    alertController.addTextField { (textField) in
      textField.placeholder = NSLocalizedString("Your name", comment: "your name")
      
      NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange,
                                             object: textField,
                                             queue: OperationQueue.main) { (notification) in
                                              saveScoreAction.isEnabled = textField.text != ""
      }
    }
    
    let cancelAction = UIAlertAction(title: NSLocalizedString("Dismiss", comment: "dismiss"), style: .cancel) { [weak self] (action) in
      self?.resetGame()
    }
    alertController.addAction(cancelAction)
    
    self.present(alertController, animated: true) { }
  }
}

