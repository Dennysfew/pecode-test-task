//
//  ViewController.swift
//  pecode-test-task
//
//  Created by Dennys Izhyk on 03.10.2023.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var searchBar: UISearchBar!
    var articles = [Article]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.updateEmptyViewVisibility()
            }
        }
    }
    
    var featuredArticles = [Article]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.updateEmptyViewVisibility()
            }
        }
    }
    
    var isSearching: Bool {
        return !searchBar.text!.isEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "News"
        emptyView.isHidden = true
        
        activityIndicator.startAnimating()
        // Fetch articles from API
        APICaller.shared.getTopStories { result in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                
                switch result {
                case .success(let fetchedArticles):
                    self.articles = fetchedArticles
                case .failure(let error):
                    self.updateEmptyViewVisibility()
                    print(error.localizedDescription)
                }
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        tableView.register(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticleTableViewCell")
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? featuredArticles.count : articles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell", for: indexPath) as! ArticleTableViewCell
        let article = isSearching ? featuredArticles[indexPath.row] : articles[indexPath.row]
        
        // Configure the cell with the article data
        cell.configure(article: article)
        
        return cell
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let trimmedText = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmedText.isEmpty else {
            // Clear the filtered articles if the search text is empty
            featuredArticles.removeAll()
            tableView.reloadData()
            return
        }
        
        APICaller.shared.search(with: trimmedText) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let articles):
                    self?.featuredArticles = articles
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.updateEmptyViewVisibility()
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func updateEmptyViewVisibility() {
        DispatchQueue.main.async {
            if self.isSearching {
                // If searching is active, show the empty view if featuredArticles is empty
                self.emptyView.isHidden = !self.featuredArticles.isEmpty
            } else {
                // If not searching, show the empty view if articles is empty
                self.emptyView.isHidden = !self.articles.isEmpty
            }
        }
    }
}
