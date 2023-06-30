//
//  TableView.swift
//  NogleMobileQuiz
//
//  Created by Peteranny on 2023/6/30.
//

import UIKit

class TableView: UITableView {
    init() {
        super.init(frame: .zero, style: .plain)

        register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
