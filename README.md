# RxFuture

A temporary solution

## What's this?

A library to provide Future/Promise pattern API that is backed by RxSwift.

## Why do we need this?

Firstly, Future/Promise pattern fits to return a single result of an asynchronous task.

```swift
func doSomething() -> Future<E>
```

Future/Promise pattern can also do with API of RxSwift only.
With using Observable or some PrimitiveSequence.

The problems in this case,
First, Observable does not know how many it will be subscribed.
So, Observable always should be shared sequence.
If it isn't, a task wrapped by Observable will run by each of subscribe.
Second, a task wrapped by Observable does not know when starts. It depends on subscribe.

The second case depends on RxSwift.
Almost of Observables in RxSwift are cold-observable.

```swift
func doSomething() -> Observable<E>
```

the name of this function says "do something", but actually, "something" will not be done until subscribed.

A below name may be better than above.

```swift
func taskToDoSomething() -> Observable<E>
```

Basically, Future will run a wrapped task immediately.
So, I created an object like as Future with RxSwift.
