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
    
    @IBOutlet var categoryButton: CategoryButton!
    @IBOutlet var countryButton: CountryButton!
    @IBOutlet var sourceButton: SourcesButton!
    @IBOutlet var searchBar: UISearchBar!
    
    let refreshControl = UIRefreshControl()
    var isLoadedAdditionalData = false
    
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
        
        fetchTopArticles()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        tableView.register(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticleTableViewCell")
        
        
        categoryButton.articleFilterHandler = { [weak self] category in
            // Handle category selection and fetch articles by category
            self?.fetchArticlesByCategory(category)
        }
        countryButton.articleFilterHandler = { [weak self] country in
            // Handle country selection and fetch articles by country
            self?.fetchArticlesByCountry(country)
        }
        
        sourceButton.articleFilterHandler = { [weak self] source in
            // Handle source selection and fetch articles by source
            self?.fetchArticlesBySource(source)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor = .purple
        tableView.addSubview(refreshControl)
    }
    
    @objc func refreshData() {
        // Perform a new API request here to fetch updated data
        fetchTopArticles()
        reloadData()
    }
    
    func reloadData() {
        self.refreshControl.endRefreshing()
        UIView.performWithoutAnimation {
            self.tableView.reloadData()
        }
    }
    
    private func fetchTopArticles() {
        isLoadedAdditionalData = false
        activityIndicator.startAnimating()
        
        APICaller.shared.getTopStories(page: 1) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.isHidden = true
                
                switch result {
                case .success(let fetchedArticles):
                    self?.articles = fetchedArticles
                case .failure(let error):
                    self?.updateEmptyViewVisibility()
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func scrollViewDidScroll (_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height-100-scrollView.frame.size.height) {
            // fetch more data
            loadNextPage()
        }
    }
    
    private func loadNextPage() {
        guard !isLoadedAdditionalData else {
            return
        }
        
        isLoadedAdditionalData = true
        
        self.tableView.tableFooterView = createSpinenrFooter ()
        // Fetch more articles for the next page
        APICaller.shared.getTopStories(page: 2) { [weak self] result in
            DispatchQueue.main.async {
                
                self?.tableView.tableFooterView = nil
                switch result {
                    
                case .success(let fetchedArticles):
                    self?.articles.append(contentsOf: fetchedArticles)
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.updateEmptyViewVisibility()
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func createSpinenrFooter() -> UIView {
        let footerView = UIView( frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        spinner.color = .purple
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }
    
    private func fetchArticlesBySource(_ sourceName: String) {
        let filteredArticles = articles.filter { $0.source.name == sourceName }
        let sortedArticles = filteredArticles.sorted { $0.title < $1.title }
        
        self.articles = sortedArticles
        self.updateEmptyViewVisibility()
    }
    
    private func fetchArticlesByCountry(_ country: String) {
        activityIndicator.startAnimating()
        APICaller.shared.getTopStoriesFilteredByCountry(country: country) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.isHidden = true
                
                switch result {
                case .success(let fetchedArticles):
                    self?.articles = fetchedArticles
                case .failure(let error):
                    self?.updateEmptyViewVisibility()
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func fetchArticlesByCategory(_ category: String) {
        activityIndicator.startAnimating()
        APICaller.shared.getTopStoriesFilteredByCategory(category: category) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.isHidden = true
                
                switch result {
                case .success(let fetchedArticles):
                    self?.articles = fetchedArticles
                case .failure(let error):
                    self?.updateEmptyViewVisibility()
                    print(error.localizedDescription)
                }
            }
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = isSearching ? featuredArticles[indexPath.row] : articles[indexPath.row]
        
        let newsArticleVC = NewsArticleViewController()
        
        // Set the articleURL property of the NewsArticleViewController to the selected article's URL
        if let articleURL = URL(string: article.url ?? "") {
            newsArticleVC.articleURL = articleURL
        }
        present(newsArticleVC, animated: true, completion: nil)
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
    @IBAction func didClearBtTapped(_ sender: Any) {
        // Clear the search bar text
        searchBar.text = ""
        
        // Clear the featured articles
        featuredArticles.removeAll()
        
        // Fetch the original articles
        fetchTopArticles()
        
        // Reset filter buttons to their default values
        resetFilterButtons()
    }
    
    private func resetFilterButtons() {
        // Set the selected values of filter buttons to their defaults
        categoryButton.resetToDefault()
        countryButton.resetToDefault()
        sourceButton.resetToDefault()
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
