# SwiftAbstract

[![Swift 版本](https://img.shields.io/badge/Swift-6.2+-orange.svg)](https://swift.org/download/)
[![许可证: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[English Version](./README.md)

SwiftAbstract 是一个 Swift 宏库，用于提供抽象类功能，类似于 Java 和 C# 等语言中的抽象类。

## 功能特性

- `@abstractClass` - 将类标记为抽象类，防止直接实例化
- `@abstractInit` - 将初始化器标记为抽象，允许子类实现自己的初始化逻辑，同时防止直接实例化
- `@abstract` - 将方法标记为抽象方法，生成 `fatalError` 强制子类重写该方法

## 安装

### Swift Package Manager

在 `Package.swift` 中添加 SwiftAbstract：

```swift
dependencies: [
    .package(url: "https://github.com/xiaoli-white/swift-abstract.git", from: "1.0.0")
]
```

然后将产品添加到你的 target 中：

```swift
.target(name: "YourTarget", dependencies: [.product(name: "SwiftAbstract", package: "swift-abstract")])
```

## 使用方法

### @abstractClass

将类标记为抽象类，防止直接实例化：

```swift
import SwiftAbstract

@abstractClass
class Animal {
    var name: String = ""
}

// 这将导致 fatal error
// let animal = Animal() // fatalError: Cannot instantiate abstract class 'Animal' directly

// 这样可以正常工作
class Dog: Animal {
    var breed: String = ""
}
let dog = Dog() // 正常
```

### @abstractInit

将初始化器标记为抽象，允许子类提供自己的实现：

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

// 这将导致 fatal error
// let person = Person(name: "John") // fatalError: Cannot instantiate abstract class 'Person' directly

// 这样可以正常工作
class Employee: Person {
    let employeeId: String
    
    init(name: String, employeeId: String) {
        self.employeeId = employeeId
        super.init(name: name)
    }
}
let employee = Employee(name: "John", employeeId: "001") // 正常
```

### @abstract

将方法标记为抽象方法。宏会生成 `fatalError`，强制子类重写该方法：

```swift
import SwiftAbstract

@abstractClass
class Vehicle {
    @abstract
    func start() {
        print    }
}

// 如果("Starting vehicle")
调用会导致 fatal error
// let vehicle = Vehicle()
// vehicle.start() // fatalError: Method 'start' must be overridden in subclass

// 这样可以正常工作 - 子类必须重写该方法
class Car: Vehicle {
    override func start() {
        print("Car started")
    }
}
let car = Car()
car.start() // 输出: Car started
```

## 重要提示

### @abstract 和 @abstractInit 必须在 @abstractClass 内使用

`@abstract` 和 `@abstractInit` 宏**必须**在带有 `@abstractClass` 标记的类内部使用。在 `@abstractClass` 外部使用将导致编译时错误：

```
@abstract can only be used inside @abstractClass
@abstractInit can only be used inside @abstractClass
```

正确使用示例：

```swift
@abstractClass
class MyClass {
    @abstractInit
    init() { }
    
    @abstract
    func myMethod() { }
}
```

## 许可证

swift-abstract 基于 MIT 许可证发布。详见 [LICENSE](LICENSE) 文件。
