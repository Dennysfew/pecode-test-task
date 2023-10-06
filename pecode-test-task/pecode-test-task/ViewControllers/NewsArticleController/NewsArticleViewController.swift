//
//  NewsArticleViewController.swift
//  pecode-test-task
//
//  Created by Dennys Izhyk on 05.10.2023.
//

import UIKit
import WebKit

class NewsArticleViewController: UIViewController {
    // MARK: - Outlets
    
    @IBOutlet var webView: WKWebView!
    
    // MARK: - Properties
    
    var articleURL: URL?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the web content if the article URL is provided
        if let url = articleURL {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

