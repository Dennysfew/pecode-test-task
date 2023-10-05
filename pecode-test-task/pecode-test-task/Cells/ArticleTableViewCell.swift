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
    
    @IBOutlet var vContent: UIView!
    @IBOutlet var articleImage: UIImageView!
    @IBOutlet var articleTitleLb: UILabel!
    @IBOutlet var articleDescriptionLb: UILabel!
    @IBOutlet var articleSourceLb: UILabel!
    @IBOutlet var articleAuthorLb: UILabel!
    @IBOutlet var heartIv: UIImageView!
    
    var article: Article?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        self.vContent.layer.cornerRadius = 10
        self.articleImage.layer.cornerRadius = 5
        
        // Add tap gesture recognizer to the heart icon
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(heartIconTapped))
        heartIv.isUserInteractionEnabled = true
        heartIv.addGestureRecognizer(tapGesture)
    }
    
    func configure(article: Article) {
        self.article = article
        articleTitleLb.text = article.title
        articleDescriptionLb.text = article.description
        articleSourceLb.text = article.source.name
        articleAuthorLb.text = article.author
        articleImage.kf.setImage(with: URL(string: article.urlToImage ?? ""))
        
        // Check if the article is saved in Core Data
        let isFavorite = checkIfArticleIsFavorite(article: article)
        
        // Update the heart icon based on the favorite status
        if isFavorite {
            // Article is a favorite, show a filled heart
            heartIv.image = UIImage(systemName: "heart.fill")
        } else {
            // Article is not a favorite, show an unfilled heart
            heartIv.image = UIImage(systemName: "heart")
        }
    }
    
    func configure(savedArticle: SavedArticle) {
        articleTitleLb.text = savedArticle.title
        articleDescriptionLb.text = savedArticle.descriptionText
        articleSourceLb.text = savedArticle.sourceName
        articleAuthorLb.text = savedArticle.author
        articleImage.kf.setImage(with: URL(string: savedArticle.urlToImage ?? ""))
        
        // Always show the filled heart for saved articles
        heartIv.image = UIImage(systemName: "heart.fill")
    }
    
    @objc func heartIconTapped() {
        guard let article = self.article else {
            return
        }
        
        // let context = CoreDataStack.shared.viewContext // Use your custom Core Data manager
        
        if checkIfArticleIsFavorite(article: article) {
            // Article is already a favorite, remove it from Core Data
            deleteArticleFromCoreData(article: article)
            print("Article Deleted from Favorites: \(article.title)")
        } else {
            // Article is not a favorite, add it to Core Data
            saveArticleToCoreData(article: article)
            print("Article Added to Favorites: \(article.title)")
        }
        
        // Toggle the heart icon with animation
        UIView.transition(with: heartIv, duration: 0.3, options: .transitionCrossDissolve, animations: {
            if self.checkIfArticleIsFavorite(article: article) {
                self.heartIv.image = UIImage(systemName: "heart.fill")
            } else {
                self.heartIv.image = UIImage(systemName: "heart")
            }
        }, completion: nil)
    }
    
    func checkIfArticleIsFavorite(article: Article) -> Bool {
        let context = CoreDataStack.shared.viewContext // Use your custom Core Data manager
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
    
    func saveArticleToCoreData(article: Article) {
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
    
    func deleteArticleFromCoreData(article: Article) {
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
}
