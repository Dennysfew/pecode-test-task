//
//  CountryButton.swift
//  pecode-test-task
//
//  Created by Dennys Izhyk on 05.10.2023.
//

import UIKit

class CountryButton: UIButton {
    var articleFilterHandler: ((String) -> Void)?
    var countries: [String] = []

    init(frame: CGRect, countries: [String], articleFilterHandler: @escaping (String) -> Void) {
        super.init(frame: frame)
        configureButton()
        setupCountries(countries)
        self.articleFilterHandler = articleFilterHandler
        setupDropdownMenu()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureButton()
        setupCountries(["us", "lv", "ru", "cz", "cu", "co"])
        setupDropdownMenu()
    }

    private func configureButton() {
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 12)
        setTitle("Country", for: .normal)
    }

    private func setupCountries(_ countries: [String]) {
        self.countries = countries
    }

    private func setupDropdownMenu() {
        let menuItems = countries.map { country in
            UIAction(title: country) { [weak self] _ in
                self?.setTitle(country, for: .normal)
                self?.articleFilterHandler?(country)
            }
        }

        let countryMenu = UIMenu(title: "Choose Country", children: menuItems)
        menu = countryMenu
        showsMenuAsPrimaryAction = true
    }
}
