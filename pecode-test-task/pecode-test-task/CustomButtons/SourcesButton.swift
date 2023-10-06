//
//  SourcesButton.swift
//  pecode-test-task
//
//  Created by Dennys Izhyk on 05.10.2023.
//

import UIKit

class SourcesButton: UIButton {
    var articleFilterHandler: ((String) -> Void)?
    var sources: [String] = []
    var defaultCategory: String = "Source"
    
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
    
    private func configureButton() {
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 12)
        setTitle("Source", for: .normal)
    }
    
    private func setupSources(_ sources: [String]) {
        self.sources = sources
    }
    
    private func setupDropdownMenu() {
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
    
    func resetToDefault() {
        // Reset the selected category to the default value
        setTitle(defaultCategory, for: .normal)
    }
}
