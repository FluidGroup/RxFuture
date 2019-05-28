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
    
//    sendMessage()
    
    let future = run().on(success: { () in
      print("success")
    }, failure: { (error) in
      print(error)
    }, completion: {
      print("complete")
    })
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      future.cancel()
    }
  }
  
  class Box {
    
  }
  
  func sendMessage() -> RxFuture<Int> {
    return
      Single<Int>.create { o in
        
        let box = Box()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { [weak box] in
          
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
  
  func run() -> RxFuture<Void> {
    
    return Single<Void>.create { o in
      
      DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
        o(.success(()))
      })
      
      return Disposables.create {
      }
      }
      .start()
  }
  
}

