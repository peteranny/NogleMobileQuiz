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

        // Install the segmented control
        view.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        // Install the table
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    private func installBindings() {
        let inputs = ViewModel.Inputs(
            selectSegment: segmentedControl.rx.selectedSegment.compactMap { Segment(rawValue: $0) },
            selectSortingCriteria: tableView.rx.sortingCriteria.asObservable()
        )

        let outputs = viewModel.bind(inputs: inputs)

        let bindSegments = outputs.segments
            .map { $0.map(\.rawValue) }
            .drive(segmentedControl.rx.segments)

        let bindSelectedSegment = outputs.selectedSegment
            .map(\.rawValue)
            .drive(segmentedControl.rx.selectedSegment)

        let bindSections = outputs.sections
            .drive(tableView.rx.sections)

        let bindSortingCriteria = outputs.sortingCriteria
            .drive(tableView.rx.sortingCriteria)

        disposeBag.insert(
            bindSegments,
            bindSelectedSegment,
            bindSections,
            bindSortingCriteria,
            outputs.binding
        )
    }

    private let viewModel = ViewModel()
    private let segmentedControl = SegmentedControl()
    private let tableView = TableView()
    private let disposeBag = DisposeBag()
}
