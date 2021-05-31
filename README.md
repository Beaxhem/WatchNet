# DyetRestApi

DyetRestApi is a modern http networking library.

* [Concept](#Concept)
* [Requirements](#Requirements)
* [Installation](#Installation)
* [Usage](#Usage)
* [Authors](#Authors)
* [Contibution](#Contibution)
* [License](#License)

# Concept

The idea is to get rid of using old-fashioned statically shared NetworkManager with lots of requests in it. Instead just  create a little service with some parameters in it. This can result in a great scaleability and easy-to-read code.

# Requirements

iOS 10.0+ / macOS 10.12+ / tvOS 10.0+ / watchOS 3.0+ (mostly)
Xcode 11+
Swift 5.1+

# Installation 

Adding the library to your project is just easy. Simply add `https://github.com/DyetApp/DyetRestApi` to the swift packages of your application 

or insert 
```
dependencies: [
    .package(url: "https://github.com/DyetApp/DyetRestApi", .upToNextMajor(from: "5.2.0"))
]
```
into your `Package.swift` file.

# Usage

This is how to create a simple service for fetching todos:

```
final class TodoService: RestJSONService {

    typealias Output = Todo // Type of the expected response

    var path: String? = "https://jsonplaceholder.typicode.com/todos/1"

    var method: HTTPMethod = .get

    var defaultParamenters: [String : String]?

    var cacheable = false // store in cache (use force parameter if needed)

}
```

Somewhere in your code: 

```
let service = TodoService()

service.execute { res in
    switch res {
        case .failure(let error):
            print(error)

        case .success(let todo):
            print(todo)
            
    }
}

```

### Builtin service for fetching images and caching them

**Note that this feature cannot be used on Macs.**

```
import AMS

***

let url = "https://via.placeholder.com/150"
imageService.shared.image(for: url) { [weak self] result in
    switch res {
    case .success(let image):
        self?.iconImageView.image = image
    case .failure(let error):
        print(error)
    
    }
    
}
  
```

Other features like adding body to POST requests are still in development. Sorry for that

# Authors

- [Illia Senchukov](https://github.com/Beaxhem)

# Contibution

If you have any ideas of how to improve the program, feel free to add new Issues on Issues page or  you can also create Pull Requests on Pull Requests page,

# License

The library is distributed under [MIT License](https://github.com/DyetApp/DyetRestApi/LICENSE)
