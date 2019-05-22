//
//  ViewController.swift
//  RxFutureDemo
//
//  Created by muukii on 2019/05/08.
//  Copyright © 2019 muukii. All rights reserved.
//

import UIKit

import RxSwift
import RxFuture

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    sendMessage()
  }
  
  class Box {
    
  }

  func sendMessage() -> RxFuture<Int> {
    return
      Single<Int>.create { o in
        
        let box = Box()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: { [weak box] in
          
          guard box != nil else {
            print("Box was deallocated")
            return
          }
          
          print("Success")
          o(.success(10))
        })
        
        return Disposables.create {
          print("Task disposed", box)
        }
        }
        .start()
  }
}

