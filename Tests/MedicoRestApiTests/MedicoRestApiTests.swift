import XCTest
@testable import MedicoRestApi


struct Todo: Codable {

    var userId: Int
    var id: Int
    var title: String
    var completed: Bool
}

final class TodoService: RestJSONService {

    typealias Output = Todo

    var path: String? = "https://jsonplaceholder.typicode.com/todos/1"

    var method: HTTPMethod = .get

    var defaultParamenters: [String : String]?

}

final class MedicoRestApiTests: XCTestCase {

    let service = TodoService()

    func testExample() {

        let expectation = XCTestExpectation()

        service.execute { res in
            switch res {
                case .failure(let error):
                    print(error)
                case .success(let todo):
                    print(todo)
                    expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10)
    }

    func imageExample() {
        let service = ImageService()

        let expectation = XCTestExpectation()

        service.image(for: "https://via.placeholder.com/150") { res in
            switch res {
                case .failure(let error):
                    print(error)
                case .success(let image):
                    print(image)
                    expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10)
    }
}
