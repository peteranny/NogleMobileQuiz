//
//  TableView.swift
//  NogleMobileQuiz
//
//  Created by Peteranny on 2023/6/30.
//

import RxDataSources
import RxSwift
import UIKit

class TableView: UITableView {
    init() {
        super.init(frame: .zero, style: .plain)

        register(TableViewCell.self, forCellReuseIdentifier: "cell")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate let dataSources = RxTableViewSectionedReloadDataSource<TableSection> { _, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.configure(item.name, price: item.price)
        return cell
    }
}

extension Reactive where Base: TableView {
    var sections: (Observable<[TableSection]>) -> Disposable {
        items(dataSource: base.dataSources)
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
