//
//  TableView.swift
//  NogleMobileQuiz
//
//  Created by Peteranny on 2023/6/30.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class TableView: UITableView {
    init() {
        super.init(frame: .zero, style: .plain)

        register(TableViewCell.self, forCellReuseIdentifier: "cell")

        rx.setDelegate(self)
            .disposed(by: disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate let dataSources = RxTableViewSectionedAnimatedDataSource<TableSection> { _, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.configure(item.name, price: item.price)
        return cell
    }

    fileprivate let headerView = TableHeaderView()
    private let disposeBag = DisposeBag()
}

extension TableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView
    }
}

extension Reactive where Base: TableView {
    var sections: (Observable<[TableSection]>) -> Disposable {
        items(dataSource: base.dataSources)
    }

    var sortingCriteria: ControlProperty<SortingCriteria> {
        base.headerView.rx.sortingCriteria
    }
}

// MARK: - TableViewCell

private class TableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ name: String, price: Double?) {
        textLabel?.text = name
        detailTextLabel?.text = price.map { NSNumber(value: $0) }.map { formatter.string(from: $0)! }
    }

    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()
}

private class TableHeaderView: UIView {
    init() {
        super.init(frame: .zero)

        let stackView = UIStackView(arrangedSubviews: [sortByNameButton, UIView(), sortByPriceButton])
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])

        stackView.axis = .horizontal
        backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate let sortByNameButton: UIButton = {
        let button = UIButton()
        button.setTitle("Name", for: .normal)
        button.setTitle("Name ▲", for: .selected)
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    fileprivate let sortByPriceButton: UIButton = {
        let button = UIButton()
        button.setTitle("Price", for: .normal)
        button.setTitle("▼ Price", for: .selected)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
}

extension Reactive where Base: TableHeaderView {
    var sortingCriteria: ControlProperty<SortingCriteria> {
        let values = Observable<SortingCriteria>.merge(
            base.sortByNameButton.rx.tap.map { .name },
            base.sortByPriceButton.rx.tap.map { .price }
        )

        let valueSink = Binder<SortingCriteria>(base) { base, criteria in
            base.sortByNameButton.isSelected = criteria == .name
            base.sortByPriceButton.isSelected = criteria == .price
        }

        return ControlProperty(values: values, valueSink: valueSink)
    }
}
