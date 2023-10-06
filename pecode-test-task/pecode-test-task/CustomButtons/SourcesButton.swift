//
//  SourcesButton.swift
//  pecode-test-task
//
//  Created by Dennys Izhyk on 05.10.2023.
//

import UIKit

class SourcesButton: UIButton {
    // MARK: - Properties
    
    var articleFilterHandler: ((String) -> Void)?
    var sources: [String] = []
    var defaultCategory: String = "Source"
    
    // MARK: - Initializers
    
    init(frame: CGRect, sources: [String], articleFilterHandler: @escaping (String) -> Void) {
        super.init(frame: frame)
        configureButton()
        setupSources(sources)
        self.articleFilterHandler = articleFilterHandler
        setupDropdownMenu()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureButton()
        setupSources(["CNN", "CBS News", "Fox", "Bloomberg"])
        setupDropdownMenu()
    }
    
    // MARK: - Private Methods
    
    private func configureButton() {
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 12)
        setTitle("Source", for: .normal)
    }
    
    private func setupSources(_ sources: [String]) {
        self.sources = sources
    }
    
    private func setupDropdownMenu() {
        // Create UIActions for each source
        let menuItems = sources.map { source in
            UIAction(title: source) { [weak self] _ in
                self?.setTitle(source, for: .normal)
                self?.articleFilterHandler?(source)
            }
        }
        
        let sourceMenu = UIMenu(title: "Choose Source", children: menuItems)
        
        menu = sourceMenu
        showsMenuAsPrimaryAction = true
    }
    
    // MARK: - Public Method
    
    func resetToDefault() {
        // Reset the selected source to the default value
        setTitle(defaultCategory, for: .normal)
    }
}
