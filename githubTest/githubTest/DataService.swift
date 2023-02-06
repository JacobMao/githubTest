import Foundation
import Combine

struct RepositoryItem: Identifiable, Decodable {
    var id: Int
    var full_name: String
    var description: String
    var stargazers_count: Int
}

struct ApiResponse: Decodable {
    var total_count: Int
    var items: [RepositoryItem]
}

protocol DataServiceProtocol {
    typealias RequestResult = Result<ApiResponse, Error>
    
    func requestData(with keyword: String) -> AnyPublisher<ApiResponse, Error>
}

struct DataService {
    // MARK: Private Properties
    private static let decoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        return jsonDecoder
    }()
}

// MARK: DataServiceProtocol
extension DataService: DataServiceProtocol {
    func requestData(with keyword: String) -> AnyPublisher<ApiResponse, Error> {
        let endPoint = URL(
            string: "https://api.github.com/search/repositories?q=\(keyword)&page=1&per_page=50"
        )!
        
        return URLSession.shared
            .dataTaskPublisher(for: endPoint)
            .map { data, _ in data }
            .decode(type: ApiResponse.self, decoder: Self.decoder)
            .eraseToAnyPublisher()
    }
}
