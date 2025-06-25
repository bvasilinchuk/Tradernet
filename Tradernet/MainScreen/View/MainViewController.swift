import UIKit

protocol MainViewInputProtocol: AnyObject {
    func reloadData()
    func showError(message: String, errorType: MainViewErrorType)
    func showLoader()
    func hideLoader()
}

class MainViewController: UIViewController {
    private let presenter: MainPresenterProtocol

    init(presenter: MainPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        makeConstraints()
        view.backgroundColor = .systemBackground
        presenter.viewDidLoad()
    }
    
    private func addSubviews() {
        view.addSubview(activityIndicator)
        view.addSubview(tableView)
    }
    
    private func makeConstraints() {
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
    }
}

extension MainViewController: MainViewInputProtocol {
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func showError(message: String, errorType: MainViewErrorType) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        switch errorType {
        case .socketError:
            alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: { _ in
                self.presenter.subscribeToDefaultQuotes()
            }))
        case .stockListError:
            alert.addAction(UIAlertAction(title: "Use default list of stocks", style: .default, handler: { _ in
                self.presenter.subscribeToDefaultQuotes()
            }))
        }
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    func showLoader() {
        activityIndicator.startAnimating()
    }

    func hideLoader() {
        activityIndicator.stopAnimating()
    }
}
