//
//  ViewController.swift
//  pecode-test-task
//
//  Created by Dennys Izhyk on 03.10.2023.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var articles = [Article]() {
        didSet {
            // Reload the table view on the main thread when the articles are updated
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.updateEmptyViewVisibility()
            }
        }
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
        
        tableView.register(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticleTableViewCell")
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell", for: indexPath) as! ArticleTableViewCell
        let article = articles[indexPath.row]
        
        // Configure the cell with the article data
        cell.configure(article: article)
        
        return cell
    }
    
    private func updateEmptyViewVisibility() {
        DispatchQueue.main.async {
            self.emptyView.isHidden = !self.articles.isEmpty
        }
    }
}
