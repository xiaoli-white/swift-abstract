# SwiftAbstract

[![Swift Version](https://img.shields.io/badge/Swift-6.2+-orange.svg)](https://swift.org/download/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[中文版本](./README_CN.md)

SwiftAbstract is a Swift macro library that provides abstract class functionality, similar to what exists in languages like Java and C#.

## Features

- `@abstractClass` - Mark a class as abstract, preventing direct instantiation
- `@abstractInit` - Mark an initializer as abstract, preventing direct instantiation while allowing subclass initialization
- `@abstract` - Mark a method as abstract, generating a `fatalError` that must be overridden by subclasses

## Installation

### Swift Package Manager

Add SwiftAbstract to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/xiaoli-white/swift-abstract.git", from: "1.0.0")
]
```

Then add the product to your target:

```swift
.target(name: "YourTarget", dependencies: [.product(name: "SwiftAbstract", package: "swift-abstract")])
```

## Usage

### @abstractClass

Mark a class as abstract to prevent direct instantiation:

```swift
import SwiftAbstract

@abstractClass
class Animal {
    var name: String = ""
}

// This will cause a fatal error
// let animal = Animal() // fatalError: Cannot instantiate abstract class 'Animal' directly

// This works
class Dog: Animal {
    var breed: String = ""
}
let dog = Dog() // OK
```

### @abstractInit

Mark an initializer as abstract while allowing subclasses to provide their own implementation:

```swift
import SwiftAbstract

@abstractClass
class Person {
    let name: String
    
    @abstractInit
    init(name: String) {
        self.name = name
    }
}

// This will cause a fatal error
// let person = Person(name: "John") // fatalError: Cannot instantiate abstract class 'Person' directly

// This works
class Employee: Person {
    let employeeId: String
    
    init(name: String, employeeId: String) {
        self.employeeId = employeeId
        super.init(name: name)
    }
}
let employee = Employee(name: "John", employeeId: "001") // OK
```

### @abstract

Mark a method as abstract. The macro generates a `fatalError` that forces subclasses to override the method:

```swift
import SwiftAbstract

@abstractClass
class Vehicle {
    @abstract
    func start() {
        print("Starting vehicle")
    }
}

// This will cause a fatal error if called
// let vehicle = Vehicle()
// vehicle.start() // fatalError: Method 'start' must be overridden in subclass

// This works - subclass must override the method
class Car: Vehicle {
    override func start() {
        print("Car started")
    }
}
let car = Car()
car.start() // Output: Car started
```

## Important Notes

### @abstract and @abstractInit must be used inside @abstractClass

The `@abstract` and `@abstractInit` macros **must** be used within a class marked with `@abstractClass`. Using them outside of `@abstractClass` will result in a compile-time error:

```
@abstract can only be used inside @abstractClass
@abstractInit can only be used inside @abstractClass
```

Example of correct usage:

```swift
@abstractClass
class MyClass {
    @abstractInit
    init() { }
    
    @abstract
    func myMethod() { }
}
```

## License

swift-abstract is released under the MIT License. See [LICENSE](LICENSE) for details.
