# WatchNet

WatchNet is a http networking library.

* [Concept](#Concept)
* [Requirements](#Requirements)
* [Installation](#Installation)
* [Usage](#Usage)
* [Authors](#Authors)
* [Contibution](#Contibution)
* [License](#License)

# Concept

The idea was to replace an old-fashioned approach of managing network requests in apps. Usually, people use something like a singleton with a lot of functions in it. It makes code not scalable and hard to maintain. So, I wanted to try to change it. Instead of creating one structure, you create services to manage each type of requests as you want. 

# Requirements

iOS 13.0+ / macOS 10.12+ / tvOS 10.0+ / watchOS 3.0+ 
Xcode 11+

# Installation 

Adding the library to your project is just easy. Simply add `https://github.com/DyetApp/WatchNet` to the swift packages of your application 

or insert 
```swift
dependencies: [
    .package(url: "https://github.com/DyetApp/WatchNet", .upToNextMajor(from: "3.0.1"))
]
```
into your `Package.swift` file.

# Usage

This is how to create a simple service for fetching todos:

```swift
final class TodoService: RestService {

    struct Todo: Codable {

        var userId: Int
        var id: Int
        var title: String
        var completed: Bool
    }

    override func path() -> String {
        "https://jsonplaceholder.typicode.com/todos/1"
    }

    override func method() -> HTTPMethod {
        .get
    }

    override func cacheable() -> Bool {
        true
    }

}
```

Somewhere in your code: 

```swift
let service = TodoService()

service.execute(decodingTo: TodoService.Todo.self) { res in
    switch res {
        case .failure(let error):
            print(error)

        case .success(let todo):
            print(todo)
            
    }
}

```

### Builtin service for fetching images and caching them

```swift

let service = ImageService()

let url = "https://via.placeholder.com/150"

service.image(for: "https://via.placeholder.com/150") { res in
    switch res {
        case .failure(let error):
            print(error)
        case .success(let image):
            imageView.image = image
    }
}
  
```

Other features like adding body to POST requests are still in development. Sorry for that

# Authors

- [Illia Senchukov](https://github.com/Beaxhem)

# Contibution

If you have any ideas of how to improve the program, feel free to add new Issues on Issues page or  you can also create Pull Requests on Pull Requests page,

# License

The library is distributed under [MIT License](https://github.com/DyetApp/WatchNet/LICENSE)
