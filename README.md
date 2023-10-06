# News Viewer App

This repository contains the source code for a News Viewer iOS app that allows users to browse, search, and favorite news articles from various sources. The app is built using Swift and UIKit and adheres to the following requirements:

## Requirements

### Task Link
[NewsAPI Documentation](https://newsapi.org/docs/get-started) - This is the API client for news viewing.

### Main Features

1. **Latest Swift Version**: The app is built using the latest version of Swift.
2. **UIKit**: The user interface is implemented using UIKit, not SwiftUI.
3. **UITableView**: Custom UITableViewCell with the following elements: source, author, title, description, and an image with a clickable link to the full news article using WKWebView.
4. **Favourite Button**: Each UITableViewCell has a favorite button to add articles to the favorite list. Data is stored using either CoreData or Realm.
5. **Saved Articles**: Users can view their saved articles in a separate UIViewController.
6. **UIRefreshControl**: Implemented for pull-to-refresh functionality.
7. **Loading Cell**: A loading cell is used for pagination, eliminating the need for a separate button.

### Main UIViewController Features

1. **Sorting**: Users can sort articles by `publishedAt`.
2. **Filtering**: Users can filter articles by category, country, or sources.
3. **Search**: A search feature allows users to search for specific articles.
4. **Pagination**: The app supports pagination for fetching more articles.
5. **API Queries**: Queries to the API are managed in a separate class.
6. **Architecture**: MVVM or MVP architecture is preferred but not required.

## Getting Started

To run this project locally, follow these steps:

1. Clone the repository to your local machine.
2. Open the project in Xcode.
3. Build and run the app on a simulator or a physical device.

## Dependencies

The project uses the following dependencies:

- [Alamofire](https://github.com/Alamofire/Alamofire): For network requests.
- [Kingfisher](https://github.com/onevcat/Kingfisher): For image downloading and caching.

Please ensure you have these dependencies installed and configured in your project.

## Contributions

Contributions to this project are welcome. If you'd like to contribute, please fork the repository, create a new branch, and submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
