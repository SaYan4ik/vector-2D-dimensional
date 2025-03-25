//
//  UITextField+Extension.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 25.03.25.
//

import Combine
import UIKit


extension UITextField {
  func textPublisher() -> AnyPublisher<String, Never> {
      NotificationCenter.default
          .publisher(for: UITextField.textDidChangeNotification, object: self)
          .map { ($0.object as? UITextField)?.text  ?? "" }
          .eraseToAnyPublisher()
  }
}
