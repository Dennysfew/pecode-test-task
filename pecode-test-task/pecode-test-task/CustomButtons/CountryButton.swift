//
//  CountryButton.swift
//  pecode-test-task
//
//  Created by Dennys Izhyk on 05.10.2023.
//

import UIKit

class CountryButton: UIButton {
    // MARK: - Properties
    
    var articleFilterHandler: ((String) -> Void)?
    var countries: [String] = []
    var defaultCategory: String = "Country"
    
    // MARK: - Initializers
    
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
    
    // MARK: - Private Methods
    
    private func configureButton() {
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 12)
        setTitle("Country", for: .normal)
    }
    
    private func setupCountries(_ countries: [String]) {
        self.countries = countries
    }
    
    private func setupDropdownMenu() {
        // Create UIActions for each country
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
    
    // MARK: - Public Method
    
    func resetToDefault() {
        // Reset the selected country to the default value and trigger the filter handler
        setTitle(defaultCategory, for: .normal)
        articleFilterHandler?("US")
    }
}
