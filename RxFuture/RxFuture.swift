//
//  RxFuture.swift
//  RxFuture
//
//  Created by muukii on 2018/12/24.
//  Copyright © 2018 muukii. All rights reserved.
//

import Foundation

#if canImport(RxSwift)
import RxSwift

public enum RxFutureError : Error {
  case wasCancelled
}

/// Item for subscribing primitive sequence
///
public struct RxFuture<E> {
  
  public typealias Result<E> = SingleEvent<E>
  
  public typealias RxPromise<E> = Single<E>

  /// Reactive style for receive notification for completion of this task.
  /// It's already shared and replaying.
  /// It will broadcast result, even if this task already completed.
  public let result: RxPromise<E>
  
  private let cancelTrigger = PublishSubject<Void>()

  public static func create(_ promise: @escaping (@escaping (SingleEvent<E>) -> ()) -> Disposable) -> RxFuture<E> {

    return .init { Single<E>.create(subscribe: promise) }
  }
  
  public static func succeed(_ value: E) -> RxFuture<E> {
    return Single<E>.just(value).start()
  }
  
  public static func fail(_ error: Swift.Error) -> RxFuture<E> {
    return Single<E>.error(error).start()
  }

  init(_ make: () -> RxPromise<E>) {

    let promise = make()
      .asObservable()
      .takeUntil(cancelTrigger)
      .asSingle()
      .catchError { error in
        guard case RxError.noElements = error else {
          throw error
        }
        throw RxFutureError.wasCancelled
      }
      .asObservable()
      .share(replay: 1, scope: .forever)
      .asSingle()

    // Single will be disposed when observed success or error.
    _ = promise.subscribe()
    
    self.result = promise
  }
 
  /// Cancel task
  public func cancel() {
    cancelTrigger.onNext(())
  }
}

extension RxFuture {
  
  /// Add notification closure for completion for this task.
  ///
  /// - Parameter execute:
  /// The closure will be called, even if this task already completed.
  @available(*, deprecated, renamed: "on")
  public func addCompletion(_ execute: @escaping (SingleEvent<E>) -> Void) {
    _ = result.subscribe(execute)
  }
  
  /// Add notification closure for completion for this task.
  ///
  /// - Parameter execute:
  /// The closure will be called, even if this task already completed.
  @discardableResult
  public func on(_ handleEvent: @escaping (SingleEvent<E>) -> Void) -> RxFuture<E> {
    _ = result.subscribe(handleEvent)
    return self
  }
  
  @discardableResult
  public func on(
    success: @escaping (E) -> Void = { _ in},
    failure: @escaping (Error) -> Void = { _ in },
    completion: @escaping () -> Void = {}
    ) -> RxFuture<E> {
    
    on { event in
      switch event {
      case .success(let e):
        success(e)
      case .error(let error):
        failure(error)
      }
      completion()
    }
    
    return self
  }
  
}

extension RxFuture {
  
  public func tweak<U>(_ tweak: (Single<E>) -> Single<U>) -> RxFuture<U> {
    return tweak(result).start()
  }
}
  
// MARK: - Transforming
extension RxFuture {
  
  public func map<U>(_ transform: @escaping (E) throws -> U) -> RxFuture<U> {
    return
      result
        .map(transform)
        .start()
  }
  
  public func flatMap<U>(_ transform: @escaping (E) throws -> RxFuture<U>) -> RxFuture<U> {
    return
      result
        .flatMap { e in
          try transform(e).result
        }
        .start()
  }

  @available(*, deprecated, renamed: "flatMap")
  public func then<U>(_ transform: @escaping (E) throws -> RxFuture<U>) -> RxFuture<U> {
    return flatMap(transform)
  }
}

extension PrimitiveSequence where Trait == SingleTrait {

  /// Subscribe and returns RunningTask
  ///
  /// - Returns:
  @discardableResult
  public func start(observeScheduler: SchedulerType = MainScheduler.asyncInstance) -> RxFuture<Element> {
    return RxFuture { observeOn(observeScheduler) }
  }
  
}

#endif
