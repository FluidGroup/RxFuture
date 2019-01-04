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
  
  public typealias RxPromise<E> = Single<E>

  /// Reactive style for receive notification for completion of this task.
  /// It's already shared and replaying.
  /// It will broadcast result, even if this task already completed.
  public let result: RxPromise<E>
  
  private let cancelTrigger = PublishSubject<Void>()

  public static func create(_ observer: @escaping (@escaping (SingleEvent<E>) -> ()) -> Disposable) -> RxFuture<E> {

    return .init { Single<E>.create(subscribe: observer) }
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
      .catchError { error in
        guard case RxError.noElements = error else {
          throw error
        }
        throw RxFutureError.wasCancelled
      }
      .share(replay: 1, scope: .forever)
      .asSingle()

    // Single will be disposed when observed success or error.
    _ = promise.subscribe()

    self.result = promise
  }

  /// Add notification closure for completion for this task.
  ///
  /// - Parameter execute:
  /// The closure will be called, even if this task already completed.
  public func addCompletion(_ execute: @escaping (SingleEvent<E>) -> Void) {
    _ = result.subscribe(execute)
  }

  /// Cancel task
  public func cancel() {
    cancelTrigger.onNext(())
  }
}

extension RxFuture {

  public func then<U>(_ closure: @escaping (E) throws -> RxFuture<U>) -> RxFuture<U> {
    return
      result
        .flatMap { e in
          try closure(e).result
        }
        .start()
  }
}

extension PrimitiveSequence where Trait == SingleTrait {

  /// Subscribe and returns RunningTask
  ///
  /// - Returns:
  public func start(observeScheduler: SchedulerType = MainScheduler.asyncInstance) -> RxFuture<Element> {
    return RxFuture { observeOn(observeScheduler) }
  }
  
}

#endif
