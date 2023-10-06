//
//  ArticleTableViewCell.swift
//  pecode-test-task
//
//  Created by Dennys Izhyk on 04.10.2023.
//

import UIKit
import Kingfisher
import CoreData

class ArticleTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet var vContent: UIView!
    @IBOutlet var articleImage: UIImageView!
    @IBOutlet var articleTitleLb: UILabel!
    @IBOutlet var articleDescriptionLb: UILabel!
    @IBOutlet var articleSourceLb: UILabel!
    @IBOutlet var articleAuthorLb: UILabel!
    @IBOutlet var heartIv: UIImageView!
    
    // MARK: - Properties
    
    var article: Article?
    
    // MARK: - View Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        addHeartIconTapGesture()
    }
    
    // MARK: - Setup Functions
    
    private func setupUI() {
        selectionStyle = .none
        vContent.layer.cornerRadius = 10
        articleImage.layer.cornerRadius = 5
    }
    
    private func addHeartIconTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(heartIconTapped))
        heartIv.isUserInteractionEnabled = true
        heartIv.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Configuration
    
    func configure(article: Article) {
        self.article = article
        articleTitleLb.text = article.title
        articleDescriptionLb.text = article.description
        articleSourceLb.text = article.source.name
        articleAuthorLb.text = article.author
        articleImage.kf.setImage(with: URL(string: article.urlToImage ?? ""))
        
        let isFavorite = checkIfArticleIsFavorite(article: article)
        updateHeartIcon(isFavorite)
    }
    
    func configure(savedArticle: SavedArticle) {
        articleTitleLb.text = savedArticle.title
        articleDescriptionLb.text = savedArticle.descriptionText
        articleSourceLb.text = savedArticle.sourceName
        articleAuthorLb.text = savedArticle.author
        articleImage.kf.setImage(with: URL(string: savedArticle.urlToImage ?? ""))
        
        updateHeartIcon(true)
    }
    
    // MARK: - Actions
    
    @objc func heartIconTapped() {
        guard let article = self.article else {
            return
        }
        
        if checkIfArticleIsFavorite(article: article) {
            deleteArticleFromCoreData(article: article)
            print("Article Deleted from Favorites: \(article.title)")
        } else {
            saveArticleToCoreData(article: article)
            print("Article Added to Favorites: \(article.title)")
        }
        
        toggleHeartIcon()
    }
    
    // MARK: - Core Data Functions
    
    private func checkIfArticleIsFavorite(article: Article) -> Bool {
        let context = CoreDataStack.shared.viewContext
        let fetchRequest: NSFetchRequest<SavedArticle> = SavedArticle.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "url == %@", article.url ?? "")
        
        do {
            let results = try context.fetch(fetchRequest)
            return !results.isEmpty
        } catch {
            print("Error fetching from Core Data: \(error)")
            return false
        }
    }
    
    private func saveArticleToCoreData(article: Article) {
        let context = CoreDataStack.shared.viewContext
        let savedArticle = SavedArticle(context: context)
        savedArticle.title = article.title
        savedArticle.descriptionText = article.description
        savedArticle.url = article.url
        savedArticle.urlToImage = article.urlToImage
        savedArticle.author = article.author
        savedArticle.sourceName = article.source.name
        savedArticle.isFavorite = true
        
        CoreDataStack.shared.saveContext()
    }
    
    private func deleteArticleFromCoreData(article: Article) {
        let context = CoreDataStack.shared.viewContext
        let fetchRequest: NSFetchRequest<SavedArticle> = SavedArticle.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "url == %@", article.url ?? "")
        
        do {
            let results = try context.fetch(fetchRequest)
            if let savedArticle = results.first {
                context.delete(savedArticle)
                CoreDataStack.shared.saveContext()
            }
        } catch {
            print("Error deleting from Core Data: \(error)")
        }
    }
    
    // MARK: - UI Updates
    
    private func toggleHeartIcon() {
        UIView.transition(with: heartIv, duration: 0.3, options: .transitionCrossDissolve, animations: {
            let isFavorite = self.checkIfArticleIsFavorite(article: self.article!)
            self.updateHeartIcon(isFavorite)
        }, completion: nil)
    }
    
    private func updateHeartIcon(_ isFavorite: Bool) {
        let imageName = isFavorite ? "heart.fill" : "heart"
        heartIv.image = UIImage(systemName: imageName)
    }
}
