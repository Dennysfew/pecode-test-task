//
//  ArticleTableViewCell.swift
//  pecode-test-task
//
//  Created by Dennys Izhyk on 04.10.2023.
//

import UIKit
import Kingfisher

class ArticleTableViewCell: UITableViewCell {
    
    @IBOutlet var vContent: UIView!
    @IBOutlet var articleImage: UIImageView!
    @IBOutlet var articleTitleLb: UILabel!
    @IBOutlet var articleDescriptionLb: UILabel!
    @IBOutlet var articleSourceLb: UILabel!
    @IBOutlet var articleAuthorLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        self.vContent.layer.cornerRadius = 10
        self.articleImage.layer.cornerRadius = 5
        
    }
    
    func configure(article: Article) {
        articleTitleLb.text = article.title
        articleDescriptionLb.text = article.description
        articleSourceLb.text = article.source.name
        articleAuthorLb.text = article.author
        articleImage.kf.setImage(with: URL(string: article.urlToImage ?? ""))
        
    }
    
}
