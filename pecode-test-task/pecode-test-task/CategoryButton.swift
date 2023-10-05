//
//  CategoryButton.swift
//  pecode-test-task
//
//  Created by Dennys Izhyk on 05.10.2023.
//

import UIKit

class CategoryButton: UIButton {
    var articleFilterHandler: ((String) -> Void)?
    var categories: [String] = []

    init(frame: CGRect, categories: [String], articleFilterHandler: @escaping (String) -> Void) {
        super.init(frame: frame)
        configureButton()
        setupCategories(categories)
        self.articleFilterHandler = articleFilterHandler
        setupDropdownMenu()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureButton()
        setupCategories(["business", "entertainment", "general", "health", "science", "sports", "technology"])
        setupDropdownMenu()
    }

    private func configureButton() {
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 12)
        setTitle("Category", for: .normal)
    }

    private func setupCategories(_ categories: [String]) {
        self.categories = categories
    }

    private func setupDropdownMenu() {
        let menuItems = categories.map { category in
            UIAction(title: category) { [weak self] _ in
                self?.setTitle(category, for: .normal)
                self?.articleFilterHandler?(category)
            }
        }

        let categoryMenu = UIMenu(title: "Choose Category", children: menuItems)
        menu = categoryMenu
        showsMenuAsPrimaryAction = true
    }
}

