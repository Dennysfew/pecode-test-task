//
//  SavedArticlesViewController.swift
//  pecode-test-task
//
//  Created by Dennys Izhyk on 05.10.2023.
//

import UIKit
import CoreData

class SavedArticlesViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    var savedArticles: [SavedArticle] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchSavedArticles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchSavedArticles()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticleTableViewCell")
    }
    
    private func fetchSavedArticles() {
        let context = CoreDataStack.shared.viewContext
        
        do {
            // Fetch saved articles from Core Data
            savedArticles = try context.fetch(SavedArticle.fetchRequest())
            
            tableView.reloadData()
        } catch {
            print("Error fetching saved articles: \(error)")
        }
    }
}

extension SavedArticlesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedArticles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell", for: indexPath) as! ArticleTableViewCell
        
        // Configure the cell with the saved article
        let savedArticle = savedArticles[indexPath.row]
        cell.configure(savedArticle: savedArticle)
        
        return cell
    }
}

