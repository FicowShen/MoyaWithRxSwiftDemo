import Foundation
import Moya

struct HomeAPI {
    let baseURL: URL
    let endpoint: HomeAPIEndpoint
}

enum HomeAPIEndpoint {
    case basicInfo
    case hobbies
}

extension HomeAPI: TargetType {

    var path: String {
        switch endpoint {
        case .basicInfo:
            return ""
        case .hobbies:
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
