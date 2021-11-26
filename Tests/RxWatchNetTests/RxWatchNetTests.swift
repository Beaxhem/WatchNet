
import XCTest
import RxWatchNet
import WatchNet
import RxSwift

final class RxTodoService: RestService {

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

final class RxWatchNetTests: XCTestCase {

    let disposeBag = DisposeBag()

    func testTodo() {
        let service = RxTodoService()

        let expectation = XCTestExpectation()

        service.rx.fetch()
            .subscribe({ todo in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 10)
    }

    func testImageService() {
        let expectation = XCTestExpectation()

        ImageService.shared.rx.fetch(path: "https://via.placeholder.com/150")
            .subscribe { image in
                expectation.fulfill()
            } onFailure: { _ in
                XCTFail()
            }
            .disposed(by: disposeBag)
    }

}
