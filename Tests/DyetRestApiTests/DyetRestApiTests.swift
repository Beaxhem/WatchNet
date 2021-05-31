import XCTest
import Cocoa
@testable import DyetRestApi

final class TodoService: RestJSONService {

    struct Todo: Codable {

        var userId: Int
        var id: Int
        var title: String
        var completed: Bool
    }

    typealias Output = Todo

    var path: String? = "https://jsonplaceholder.typicode.com/todos/1"

    var method: HTTPMethod = .get

    var defaultParamenters: [String : String]?

    var cacheable = false

}

final class BadMethodService: RestJSONService {

    struct Todo: Codable {

        var userId: Int
        var id: Int
        var title: String
        var completed: Bool
    }

    typealias Output = Todo

    var path: String? = "https://jsonplaceholder.typicode.com/todos/1"

    var method: HTTPMethod = .post

    var defaultParamenters: [String : String]?

    var cacheable = false

}

final class CommentsService: RestJSONService {

    struct Comment: Decodable {

        var postId: Int
        var id: Int
        var name: String
        var email: String
        var body: String

    }

    typealias Output = [Comment]

    var path: String? = "https://jsonplaceholder.typicode.com/comments"

    var method: HTTPMethod = .get

    var defaultParamenters: [String : String]?

    var cacheable = false

}

struct BadURLService:  RestJSONService {

    struct Todo: Codable {

        var userId: Int
        var id: Int
        var title: String
        var completed: Bool
    }

    typealias Output = Todo

    var path: String? = "jsonplaceholder.typicode.com/tod/1"

    var method: HTTPMethod = .get

    var defaultParamenters: [String : String]?

    var cacheable = false

}

final class MedicoRestApiTests: XCTestCase {

    func testTodoService() {

        let service = TodoService()

        let expectation = XCTestExpectation()

        service.execute { res in
            switch res {
                case .failure(let error):
                    print(error)
                    XCTFail()
                case .success(let todo):
                    print(todo)
                    expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10)
    }

    func testBadTodoService() {

        let service = BadMethodService()

        let expectation = XCTestExpectation()

        service.execute { res in
            switch res {
                case .failure(let error):

                    switch error {
                        case .notFound:
                            expectation.fulfill()
                        default:
                            XCTFail()
                    }

                case .success:
                    XCTFail()
            }
        }

        wait(for: [expectation], timeout: 10)
    }

    func testImageExample() {
        let expectation = XCTestExpectation()

        let service = ImageService()

        service.image(for: "https://via.placeholder.com/150") { res in
            switch res {
                case .failure(let error):
                    print(error)
                    XCTFail()
                case .success:
                    expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10)
    }

    func testCommentsExample() {

        let service = CommentsService()

        let expectation = XCTestExpectation()

        service.execute(parameters: ["postId": "1"]) { res in
            switch res {
                case .failure(let error):
                    print(error)
                    XCTFail()
                case .success:
                    expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10)

    }

    func testBadURL() {
        let service = BadURLService()

        let expectation = XCTestExpectation()

        service.execute { res in

            switch res {
                case .failure(let error):

                    switch error {
                        case .notFound:
                            expectation.fulfill()
                        default:
                            XCTFail()
                    }

                case .success:
                    XCTFail()
            }
        }

        wait(for: [expectation], timeout: 10)
    }

    func testCache() {
        let expectation = XCTestExpectation()

        func check(image1: UIImage, image2: UIImage) -> Bool {
            #if !os(macOS)
            return image1.pngData() == image2.pngData()
            #else
            return image1.tiffRepresentation(using: .jpeg, factor: 1) == image2.tiffRepresentation(using: .jpeg, factor: 1)
            #endif
        }

        let service = ImageService()

        var image: UIImage?

        service.image(for: "https://via.placeholder.com/150", force: true) { res in
            switch res {
                case .failure(let error):
                    print(error)
                    XCTFail()
                case .success(let data):
                    image = data
                    break
            }
        }

        sleep(3)

        service.image(for: "https://via.placeholder.com/150") { res in
            switch res {
                case .failure(let error):
                    print(error)
                    XCTFail()
                case .success(let data):

                    guard let image = image,
                          check(image1: image, image2: data) else {
                        return
                    }
                    expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10)
    }
}
