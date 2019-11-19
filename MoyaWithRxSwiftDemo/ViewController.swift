import UIKit
import RxSwift

func logError(_ error: Error, function: String = #function) {
    print(function + ", Error:", error.localizedDescription)
}

class ViewController: UIViewController {

    @IBOutlet weak var myTableView: UITableView! {
        didSet {
            myTableView.register(UITableViewCell.self, forCellReuseIdentifier: SimpleCell.reuseId)
            myTableView.delegate = self
            myTableView.dataSource = self
            myTableView.tableHeaderView = UIView()
            myTableView.tableFooterView = UIView()
        }
    }

    var models = [Any]()

    private lazy var networkHelper = HomeNetworkHelper(baseURL: baseURL)

    private let baseURL = URL(string: "")!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadFirstRow()
        loadSecondRow()
    }

    func loadFirstRow() {
        networkHelper
            .fetchBasicInfo()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (model) in
                self.models.insert(model, at: 0)
                self.myTableView.reloadData()
            }, onError: { (error) in
                logError(error)
            }).disposed(by: disposeBag)
    }

    func loadSecondRow() {
        networkHelper
            .fetchHobbies()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (model) in
                self.models.append(model)
                self.myTableView.reloadData()
            }, onError: { (error) in
                logError(error)
            }).disposed(by: disposeBag)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SimpleCell.reuseId, for: indexPath)
        switch models[indexPath.row] {
        case let basicInfo as UserBasicInfo:
            cell.textLabel?.text = basicInfo.name
            cell.detailTextLabel?.text = basicInfo.age.description
        case let hobbies as UserHobbies:
            cell.textLabel?.text = hobbies.hobbies.joined(separator: ",")
            cell.detailTextLabel?.text = nil
        default: break
        }
        return cell
    }

}

