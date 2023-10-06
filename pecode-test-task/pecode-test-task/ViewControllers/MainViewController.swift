//
//  MainViewController.swift
//  pecode-test-task
//
//  Created by Dennys Izhyk on 03.10.2023.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var categoryButton: CategoryButton!
    @IBOutlet var countryButton: CountryButton!
    @IBOutlet var sourceButton: SourcesButton!
    @IBOutlet var searchBar: UISearchBar!
    
    // MARK: - Properties
    
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
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "News"
        emptyView.isHidden = true
        
        setupUI()
        setupTableView()
        setupSearchBar()
        setupRefreshControl()
        fetchTopArticles()
    }
    
    // MARK: - Setup Functions
    
    private func setupUI() {
        categoryButton.articleFilterHandler = { [weak self] category in
            self?.fetchArticlesByCategory(category)
        }
        
        countryButton.articleFilterHandler = { [weak self] country in
            self?.fetchArticlesByCountry(country)
        }
        
        sourceButton.articleFilterHandler = { [weak self] source in
            self?.fetchArticlesBySource(source)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticleTableViewCell")
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor = .purple
        tableView.addSubview(refreshControl)
    }
    
    // MARK: - Data Refresh
    
    @objc private func refreshData() {
        fetchTopArticles()
        reloadData()
    }
    
    private func reloadData() {
        refreshControl.endRefreshing()
        UIView.performWithoutAnimation {
            tableView.reloadData()
        }
    }
    
    // MARK: - Top Article Fetching
    
    private func fetchTopArticles() {
        isLoadedAdditionalData = false
        activityIndicator.startAnimating()
        
        // Used First Page Of API Data
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
    
    // MARK: - Pagination
    
    func scrollViewDidScroll (_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height-100-scrollView.frame.size.height) {
            // Fetch More Fata
            loadNextPage()
        }
    }
    
    private func loadNextPage() {
        guard !isLoadedAdditionalData else {
            return
        }
        
        isLoadedAdditionalData = true
        
        tableView.tableFooterView = createSpinnerFooter()
        
        // Used Second Page Of API Data
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
    
    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        spinner.color = .purple
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }
    
    // MARK: - Filtering Functions
    
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
        
        cell.configure(article: article)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = isSearching ? featuredArticles[indexPath.row] : articles[indexPath.row]
        
        let newsArticleVC = NewsArticleViewController()
        
        if let articleURL = URL(string: article.url ?? "") {
            newsArticleVC.articleURL = articleURL
        }
        present(newsArticleVC, animated: true, completion: nil)
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let trimmedText = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmedText.isEmpty else {
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
    
    // MARK: - Actions
    
    @IBAction func didClearBtTapped(_ sender: Any) {
        searchBar.text = ""
        featuredArticles.removeAll()
        fetchTopArticles()
        resetFilterButtons()
    }
    
    private func resetFilterButtons() {
        categoryButton.resetToDefault()
        countryButton.resetToDefault()
        sourceButton.resetToDefault()
    }
    
    private func updateEmptyViewVisibility() {
        DispatchQueue.main.async {
            if self.isSearching {
                self.emptyView.isHidden = !self.featuredArticles.isEmpty
            } else {
                self.emptyView.isHidden = !self.articles.isEmpty
            }
        }
    }
}
