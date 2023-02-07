import XCTest
import Combine
@testable import githubTest

private final class MockService: DataServiceProtocol {
    var mockSignal = PassthroughSubject<githubTest.ApiResponse, Error>()
    var callTimes = 0
    var currentExpectation: XCTestExpectation?
    
    func requestData(with keyword: String) -> AnyPublisher<githubTest.ApiResponse, Error> {
        callTimes += 1
        currentExpectation?.fulfill()
        
        return mockSignal.eraseToAnyPublisher()
    }
}

final class ViewModelTests: XCTestCase {
    private let mockService = MockService()

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSearchText() throws {
        let viewModel = ViewModel(dataService: mockService)
        
        // Test input search text
        
        var expectation = self.expectation(description: "testSearchText")
        mockService.currentExpectation = expectation
        
        viewModel.searchText = "a"
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(mockService.callTimes, 1, "data service should be called")
        
        // Test input search text is same with previous one
        
        expectation = self.expectation(description: "testSearchText")
        
        viewModel.searchText = "a"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(mockService.callTimes, 1, "data service shouldn't be called for same search text")
        
        // Test throttling
        
        expectation = self.expectation(description: "testSearchText")
        mockService.currentExpectation = expectation
        
        viewModel.searchText = "aa"
        viewModel.searchText = "aaa"
        viewModel.searchText = "aaaa"
        
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertEqual(mockService.callTimes, 2, "data service should be throttling")
    }
    
    func testLoadData() throws {
        let viewModel = ViewModel(dataService: mockService)
        let mockResponse = ApiResponse(
            total_count: 3,
            items: [
                RepositoryItem(id: 1, full_name: "foo1", stargazers_count: 3),
                RepositoryItem(id: 2, full_name: "foo2", stargazers_count: 4),
                RepositoryItem(id: 3, full_name: "foo3", stargazers_count: 5),
            ]
        )
        
        // test loading data
        
        viewModel.loadData(with: "a")
        
        mockService.mockSignal.send(mockResponse)
        
        var expectation = self.expectation(description: "testLoadData")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(viewModel.items.count, 3, "received item count should be 3")
        
        // test keyword is empty
        
        viewModel.loadData(with: "")
        XCTAssertTrue(viewModel.items.isEmpty, "item list should be empty if keyword is empty")
        
        // test error case
        
        viewModel.loadData(with: "a")
        
        mockService.mockSignal.send(completion: .failure(NSError(domain: "foo", code: 101)))
        
        expectation = self.expectation(description: "testLoadData")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertTrue(viewModel.presentAlert, "presentAlert should be true")
        
        let receivedError = viewModel.latestError! as NSError
        XCTAssertEqual(receivedError.domain, "foo", "received error is wrong")
        XCTAssertEqual(receivedError.code, 101, "received error is wrong")
    }
}
