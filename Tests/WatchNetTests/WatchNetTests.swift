import XCTest

import WatchNet

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

final class BadMethodService: RestService {

    override func path() -> String {
        "https://jsonplaceholder.typicode.com/todos/1"
    }

    override func method() -> HTTPMethod {
        .post
    }

    override func cacheable() -> Bool {
        false
    }

}

final class CommentsService: RestService {

    struct Comment: Decodable {

        var postId: Int
        var id: Int
        var name: String
        var email: String
        var body: String

    }

    override func path() -> String {
        "https://jsonplaceholder.typicode.com/comments"
    }

    override func method() -> HTTPMethod {
        .get
    }

    override func cacheable() -> Bool {
        false
    }

    override func parameters() -> [String : String]? {
        ["postId": "1"]
    }
}

final class BadURLService: RestService {

    struct Todo: Codable {

        var userId: Int
        var id: Int
        var title: String
        var completed: Bool
    }

    override func path() -> String {
        "jsonplaceholder.typicode.com/tod/1"
    }

    override func method() -> HTTPMethod {
        .get
    }

    override func cacheable() -> Bool {
        false
    }

}

final class WatchNetTests: XCTestCase {

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
                case .success(let image):
                    expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10)
    }

    func testCommentsExample() {

        let service = CommentsService()

        let expectation = XCTestExpectation()

        service.execute { res in
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
