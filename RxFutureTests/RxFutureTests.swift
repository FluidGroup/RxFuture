//
//  RxFutureTests.swift
//  RxFutureTests
//
//  Created by muukii on 2020/02/19.
//  Copyright © 2020 muukii. All rights reserved.
//

import XCTest

import RxSwift
import RxFuture

class RxFutureTests: XCTestCase {
  
  enum Error: Swift.Error {
    case something
  }
  
  class DeinitBox {
    
    var onDeinit: () -> Void = {}
    
    init(_ onDeinit: @escaping () -> Void) {
      self.onDeinit = onDeinit
    }
    
    deinit {
      onDeinit()
      print("Deinit")
    }
  }
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func runMyTask() -> RxFuture<Int> {
    
    return .create { (promise) -> Disposable in
      DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
        promise(.success(100))
      }
      return Disposables.create()
    }
    
  }
  
  var cache: RxFuture<Int>?
  
  func testReleasing() {
      
    let exp = XCTestExpectation()
    let exp2 = XCTestExpectation()
    
    DispatchQueue.main.async {
      let box = DeinitBox {
        exp.fulfill()
      }
      
      self.cache =
        self.runMyTask().tweak {
          $0.do(onSuccess: { _ in print(box) })
        }
        .on(success: { _ in
          exp2.fulfill()
        })

    }
           
    wait(for: [exp, exp2], timeout: 3)

  }
  
  func testMulti() {
    
    let exp1 = XCTestExpectation()
    let exp2 = XCTestExpectation()
    let exp3 = XCTestExpectation()
    
    let future = self.runMyTask()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
      future
        .on(success: { _ in
          exp1.fulfill()
        })
      
      DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
        future
          .on(success: { _ in
            exp2.fulfill()
          })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
          future
            .on(success: { _ in
              exp3.fulfill()
            })
        }
      }
      
    }
          
    wait(for: [exp1, exp2, exp3], timeout: 3)

  }
  
  func testMultiWithError() {
    
    let exp1 = XCTestExpectation()
    let exp2 = XCTestExpectation()
    let exp3 = XCTestExpectation()
    
    let future = self.runMyTask()
      .tweak {
        $0.map {
          _ in throw Error.something          
        }
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
      future
        .on(failure: { _ in
          exp1.fulfill()
        })
      
      DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
        future
          .on(failure: { _ in
            exp2.fulfill()
          })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
          future
            .on(failure: { _ in
              exp3.fulfill()
            })
        }
      }
      
    }
    
    wait(for: [exp1, exp2, exp3], timeout: 3)
    
  }
  
  func testNoSubscribe() {
    
    let future = self.runMyTask()
    
    XCTAssertEqual(future.isCompleted, false)

    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2)) {
      XCTAssertEqual(future.isCompleted, true)
    }
    
  }
  
  func testSourceLifetime() {
    
    let exp1 = XCTestExpectation()
           
    DispatchQueue.main.async {
      
      var task: RxFuture? = RxFuture<Int>.create { promise in
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5)) {
          promise(.success(100))
        }
        
        return Disposables.create {
          // Test will be finished faster than below
          XCTFail()
        }
      }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2)) {
        task = nil
        exp1.fulfill()
      }
      
    }
            
    wait(for: [exp1], timeout: 10)
  }
  
}
