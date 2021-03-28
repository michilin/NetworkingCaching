//
//  UsersViewController.swift
//  NetworkingCaching
//
//  Created by mickey on 28/03/2021.
//  
//

import UIKit

protocol UsersViewable: class {
    func updateViewModel(_: UsersViewModel)
    func presentError(_: String)
}

final class UsersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var interactor: UsersInteractable?
    private var router: UsersRoutable?
    private var viewModel = UsersViewModel(cellViewModels: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    func bind(to interactor: UsersInteractable?, and router: UsersRoutable) {
        self.interactor = interactor
        self.router = router
    }
}

extension UsersViewController: UsersViewable {

    func updateViewModel(_ viewModel: UsersViewModel) {
        self.viewModel = viewModel
        tableView.reloadData()
    }

    func presentError(_ errorMessage: String) {
        let alertController = UIAlertController(
            title: "Error",
            message: errorMessage,
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style: .cancel,
            handler: nil)
        alertController.addAction(okAction)
        navigationController?.present(alertController, animated: true, completion: nil)
    }
}

extension UsersViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellViewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else {
            return UITableViewCell()
        }
        let cellViewModel = viewModel.cellViewModels[indexPath.row]
        cell.textLabel?.text = cellViewModel.name
        cell.detailTextLabel?.text = cellViewModel.email
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height else { return }
        interactor?.fetchUsers()
    }
}
