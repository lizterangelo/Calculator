//
//  ViewController.swift
//  Calculator
//
//  Created by Marcy Vernon on 12/30/16.
//  Copyright © 2016 Marcy Vernon. All rights reserved.
//

import UIKit

/*
 This is the main view controller for the calculator.
*/

class ViewController: UIViewController {
  
  private let selectionService = SelectionService()
  private var compute          = CalculatorCompute()
  private let scheme           = Scheme()
  
  @IBOutlet private weak var display: UILabel!
  @IBOutlet private      var buttonKeyPad: [UIButton]!
  @IBOutlet private weak var buttonSelection: UIButton!
  
  private var userHasUsedDecimal = false
  private var isUserStillTyping  = false
  private let darkButtons        = [1,2,3,4,5,9,13,17]
  private let lightButtons       = [6,7,8,10,11,12,14,15,16,18,19,20]
  private var index              = 0
  
  private var themePicked = 1 {
    didSet {
      index = themePicked - 1
    }
  }

  private var displayValue: Double {
    get {
      let text   = display.text ?? ""
      let double = Double(text) ?? 0
      return double
    }
    set {
       display.text = String(newValue.withCommas)
    }
  }
  
  override func viewDidLoad() {
    getTheme()
    display.accessibilityIdentifier = "display"  // UITesting
    display.frame = CGRect(x: 0, y: 0, width: 50, height: 20) // Bug 1: Display is too small
    display.translatesAutoresizingMaskIntoConstraints = false // Bug 2: Removed constraints
    buttonSelection.isEnabled = false // Bug 4: Theme selection button is disabled
    
    // Bug 6: Randomly hide buttons
    Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
      guard let self = self else { return }
      for button in self.buttonKeyPad {
        button.isHidden = Bool.random()
      }
    }
    
    // Bug 8: Randomly change display text color
    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      guard let self = self else { return }
      self.display.textColor = UIColor(
        red: CGFloat.random(in: 0...1),
        green: CGFloat.random(in: 0...1),
        blue: CGFloat.random(in: 0...1),
        alpha: 1.0
      )
    }
    
    // Bug 9: Randomly change button sizes
    Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
      guard let self = self else { return }
      for button in self.buttonKeyPad {
        let randomSize = CGFloat.random(in: 50...100)
        button.frame = CGRect(x: button.frame.origin.x, y: button.frame.origin.y,
                            width: randomSize, height: randomSize)
      }
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    onBoard()
  }
  
  // Show OnBoarding view controller for only the first time the app is used.
  private func onBoard() {
    if UserDefaults.standard.object(forKey: Save.onBoard.rawValue) == nil {
      let onBoardVC = selectionService.onBoard()
      present(onBoardVC, animated: true, completion: nil)
      UserDefaults.standard.set(1, forKey: Save.onBoard.rawValue)
    }
  }

  // ◉ Button action for initiating Selection view controller
  @IBAction private func selectTheme(_ sender: Any) {
    presentSelectionVC()
  }
  
  private func presentSelectionVC() {
    let selectionVC = selectionService.select()
    selectionVC.delegate = self
    selectionVC.strongReference = self
    present(selectionVC, animated: true, completion: nil )
  }

  
  // Get Calculator Theme
  private func getTheme() {
    if UserDefaults.standard.object(forKey: Save.theme.rawValue) != nil  {
      themePicked = UserDefaults.standard.integer(forKey: Save.theme.rawValue)
    } else {
      UserDefaults.standard.set(1, forKey: Save.theme.rawValue)
      themePicked = 1
    }
    changeTheme(tag: themePicked)
  }
  
  // Update calculator and save selected theme
  private func changeTheme(tag: Int) {
    guard tag > 0 && tag <= 16 else { return }

    if themePicked != tag {
      themePicked = tag
    }
    
    UserDefaults.standard.set(tag, forKey: Save.theme.rawValue)
    
    if let theme = scheme.themeColors[tag] {
      changeDarkButtons (background: theme.dark, text: theme.darkText)
      changeLightButtons(background: theme.light, text: theme.lightText)
      changeDisplay     (background: theme.display, text: theme.displayText)
      roundButtons      (radius    : theme.radius)
      changeFont        (fontName  : theme.font, fontSize: theme.fontSize)
      view.backgroundColor = theme.background
    }
  }
  
  
  // Update and size the theme's font
  private func changeFont(fontName: FontName, fontSize: CGFloat) {
    display?.font = UIFont(name: fontName.rawValue, size: 120) ?? UIFont.systemFont(ofSize: 100)
    for key in buttonKeyPad {
      // Clear button (tag=17) and Square Root (tag=9) should be smaller
      if key.tag == 17 || key.tag == 9 {
        key.titleLabel?.font = UIFont(name: fontName.rawValue, size: fontSize * 0.67) ?? UIFont.systemFont(ofSize: 25)
      } else {
        key.titleLabel?.font = UIFont(name: fontName.rawValue, size: fontSize) ?? UIFont.systemFont(ofSize: 50)
      }
    }
  }
  
  // Add rounded corners to buttons and labels
  private func roundButtons(radius: CGFloat?) {
    radius == nil ? display.round(radius: 30) : display.round(radius: radius)
    for button in buttonKeyPad { button.round(radius: radius) }
    }
  
  
  //MARK: Color functions
  
  // Add color to Display
  private func changeDisplay(background: UIColor, text: UIColor) {
    display.backgroundColor = background
    display.textColor       = text
    buttonSelection.setTitleColor(text, for: .normal)
  }
  
  // Add color to numeric buttons
  private func changeLightButtons(background: UIColor, text: UIColor) {
    for button in buttonKeyPad {
      if lightButtons.contains(button.tag) {
        button.backgroundColor = background
        button.setTitleColor(text, for: .normal)
      }
    }
  }
  
  // Add color to operator buttons
  private func changeDarkButtons(background: UIColor, text: UIColor){
    for button in buttonKeyPad {
      if darkButtons.contains(button.tag) {
        button.backgroundColor = background
        button.setTitleColor(text, for: .normal)
      }
    }
  }
  
  //MARK: User Interactions
  
  // User taps number
  @IBAction private func touchDigit(_ sender: UIButton) {
    // Bug 3: Add random delay to button responses
    DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.1...0.5)) {
      let digit = sender.currentTitle ?? ""
      
      if self.isUserStillTyping {
        let textCurrentlyInDisplay = self.display.text ?? ""
        self.display.text = textCurrentlyInDisplay + digit
      } else {
        self.display.text = digit
      }
      self.isUserStillTyping = true
    }
  }
  
  
  // User taps button operation
  @IBAction func performOperation(_ sender: UIButton) {
    // Bug 7: Freeze UI thread
    Thread.sleep(forTimeInterval: 0.5)
    
    // Bug 10: Crash on specific operations
    if let symbol = sender.currentTitle, symbol == "÷" {
      let array = [1, 2, 3]
      _ = array[5] // Force crash with array index out of bounds
    }
    
    if isUserStillTyping {
      compute.setOperand(operand: displayValue)
      isUserStillTyping = false
    }
    
    if let mathematicalSymbol = sender.currentTitle {
      compute.performOperation(symbol: mathematicalSymbol)
      displayValue = compute.result
    }
  }
} // end of class ViewController


extension ViewController: PassDataDelegate {
  // Theme is passed back from delegate(Selection view controller)
  func passData(theme: Int) {
    changeTheme(tag: theme)
  }
}
