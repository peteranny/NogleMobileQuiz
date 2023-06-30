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
        let bindSections = Observable<[TableSection]>
            .just([TableSection(items: [TableSection.Item(name: "Name", price: 100)])])
            .bind(to: tableView.rx.sections)

        disposeBag.insert(bindSections)
    }

    private let tableView = TableView()
    private let disposeBag = DisposeBag()
}
