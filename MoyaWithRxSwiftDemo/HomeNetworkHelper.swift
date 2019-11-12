import Foundation
import Moya
import RxSwift

final class HomeNetworkHelper {

    private let baseURL: URL
    private let moyaProvider: MoyaProvider<HomeAPI>

    init(baseURL: URL,
         moyaProvider: MoyaProvider<HomeAPI> = MoyaProvider<HomeAPI>()) {
        self.baseURL = baseURL
        self.moyaProvider = moyaProvider
    }

    func fetchFirstRow() -> Observable<SimpleModel> {
        return Observable.create { (observer) -> Disposable in
            let api = HomeAPI(baseURL: self.baseURL, endpoint: .firstRow)
            self.requestAPI(api: api, observer: observer)
            return Disposables.create()
        }.observeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    func fetchSecondRow() -> Observable<SimpleModel> {
        return Observable.create { (observer) -> Disposable in
            let api = HomeAPI(baseURL: self.baseURL, endpoint: .secondRow)
            self.requestAPI(api: api, observer: observer)
            return Disposables.create()
        }.observeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    func requestAPI(api: HomeAPI, observer: AnyObserver<SimpleModel>) {
        self.moyaProvider.request(api) { (response) in
            switch response {
            case .success(let value):
                do {
                    let result = try value.map(SimpleModel.self, atKeyPath: nil, using: JSONDecoder(), failsOnEmptyData: false)
                    observer.onNext(result)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            case .failure(let error):
                observer.onError(error)
            }
        }
    }
}
