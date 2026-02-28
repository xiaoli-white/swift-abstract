import SwiftAbstract

@abstractClass
class Animal {
    var name: String = ""
}

@abstractClass
class Person {
    let name: String
    
    @abstractInit
    init(name: String) {
        self.name = name
    }
}

@abstractClass
class Vehicle {
    @abstract
    func start() {
        print("Starting vehicle")
    }
}
class Car: Vehicle {
    override func start() {
        print("Car started")
    }
}
let car = Car()
car.start()
