import Foundation
import Moya

struct HomeAPI {
    let baseURL: URL
    let endpoint: HomeAPIEndpoint
}

enum HomeAPIEndpoint {
    case firstRow
    case secondRow
}

extension HomeAPI: TargetType {

    var path: String {
        switch endpoint {
        case .firstRow:
            return ""
        case .secondRow:
            return ""
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        return .requestParameters(parameters: [:], encoding: URLEncoding.queryString)
    }

    var headers: [String : String]? { nil }

    var sampleData: Data { Data() }
}
