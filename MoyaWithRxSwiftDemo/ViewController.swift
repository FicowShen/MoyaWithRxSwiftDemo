import UIKit
import RxSwift

struct SimpleModel: Codable {
    let title: String
    let description: String?
}

func logError(_ error: Error, function: String = #function) {
    print(function + ", Error:", error.localizedDescription)
}

class ViewController: UIViewController {

    @IBOutlet weak var myTableView: UITableView! {
        didSet {
            myTableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
            myTableView.delegate = self
            myTableView.dataSource = self
            myTableView.tableHeaderView = UIView()
            myTableView.tableFooterView = UIView()
        }
    }

    var models = [SimpleModel]()

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
            .fetchFirstRow()
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
            .fetchSecondRow()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = models[indexPath.row].title
        cell.detailTextLabel?.text = models[indexPath.row].description
        return cell
    }


}

