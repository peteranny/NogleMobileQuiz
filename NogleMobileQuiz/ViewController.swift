//
//  ViewController.swift
//  NogleMobileQuiz
//
//  Created by Peteranny on 2023/6/30.
//

import Foundation
import RxSwift
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        installSubviews()
        installBindings()
    }

    private func installSubviews() {
        view.backgroundColor = .white

        // Install the table
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    private func installBindings() {
        let inputs = ViewModel.Inputs()
        let outputs = viewModel.bind(inputs: inputs)

        let bindSections = outputs.sections
            .drive(tableView.rx.sections)

        disposeBag.insert(bindSections)
    }

    private let viewModel = ViewModel()
    private let tableView = TableView()
    private let disposeBag = DisposeBag()
}
