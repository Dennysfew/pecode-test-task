//
//  NewsArticleViewController.swift
//  pecode-test-task
//
//  Created by Dennys Izhyk on 05.10.2023.
//

import UIKit
import WebKit

class NewsArticleViewController: UIViewController {
    @IBOutlet var webView: WKWebView!
    var articleURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = articleURL {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
