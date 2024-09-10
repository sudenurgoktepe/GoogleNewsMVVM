import UIKit

extension Notification.Name {
    static let notificationSearch = Notification.Name(rawValue: "NotificationSearch")
 
}

extension SearchViewController: UIScrollViewScrollToTop {
 
    func scrollToTop() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if !searchViewModel.searchResults.isEmpty{
                let indexPath = IndexPath(row: 0, section: 0)
                searchTableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }
}

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, CustomTableViewCellDelegate,UITabBarControllerDelegate{
    private let searchViewModel = SearchViewModel()
  
    @IBOutlet var searchTableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var searchLabel: UILabel!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotifications()
        setupSearchBar()
        setupTableView()
        setupNavigationBar()
        setupSearchViewModel()
        setupTapGestureRecognizer()
    }

    private func setupTableView(){
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchLabel.isHidden = false
        searchTableView.isHidden = true
        
        let nib = UINib(nibName: searchViewModel.headerNibName, bundle: nil)
        
        searchTableView.register(nib, forCellReuseIdentifier:searchViewModel.headerNibName)
        searchTableView.rowHeight = UITableView.automaticDimension
        searchTableView.estimatedRowHeight = 150
        
    }
    
    private func setupNavigationBar(){
        navigationItem.title = searchViewModel.searchTitle
    }
    
    private func setupNotifications(){
        let notificationCenter: NotificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.loadFavoritesA), name: .notificationSearch, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.updateFavorite(notification:)), name: .notificationFavorite, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.updateFavorite(notification:)), name: .notificationNews, object: nil)
    }
    
    private func setupTapGestureRecognizer(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
    }
    
    private func setupSearchViewModel(){
        searchViewModel.delegate = self
        searchViewModel.loadFavorites()
    }
    
    private func setupSearchBar(){
        searchBar.delegate = self
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let searchText = searchBar.text,searchText.isEmpty {
            searchLabel.isHidden = false
            searchTableView.isHidden = true
        } else {
            searchLabel.isHidden = true
            searchTableView.isHidden = false
        }
        self.tabBarController?.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
      if tabBarController.selectedIndex == 1, let navController = viewController as? UINavigationController {
          navController.popToRootViewController(animated: true)
          if let topVC = navController.topViewController as? UIScrollViewScrollToTop {
              topVC.scrollToTop()
          }
      }
  }
    
    @objc func loadFavoritesA() {
        searchViewModel.loadFavorites()
    }
    
    @objc func updateFavorite(notification: Notification) {
        debugPrint("notificaiton geldi search")
        guard let updatedArticle = notification.object as? Article else { return }
        debugPrint("notificaiton geldi search current stat",updatedArticle.isFavorited)
        if let fIndex = self.searchViewModel.searchResults.firstIndex(where: {$0.url == updatedArticle.url}) {
            debugPrint("Toggle etti")
            self.searchViewModel.searchResults[fIndex].isFavorited?.toggle()
        }
        searchTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNewsDetailsVC" {
            if let indexPath = searchTableView.indexPathForSelectedRow {
                let selectedArticle = searchViewModel.searchResults[indexPath.row]
                let destinationVC = segue.destination as! NewsDetailsViewController
                if let urlString = selectedArticle.url, let url = URL(string: urlString) {
                    destinationVC.articleURL = url
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toNewsDetailsVC", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModel.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: searchViewModel.headerNibName, for: indexPath) as! CustomTableViewCell
        let article = searchViewModel.searchResults[indexPath.row]
        cell.article = article
        cell.setUI()
        cell.delegate = self
        return cell
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        searchViewModel.searchResults.removeAll()
        searchLabel.isHidden = true
        searchTableView.isHidden = false
        searchViewModel.fetchNews()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            searchLabel.isHidden = false
            searchTableView.isHidden = true
        } else {
            searchLabel.isHidden = true
            searchTableView.isHidden = false
        }
    }
    
    func didTapFavoriteButton(on cell: CustomTableViewCell) {
        guard let article = cell.article, let fIndex = self.searchViewModel.searchResults.firstIndex(where: { $0.url == article.url }) else { return }
        searchViewModel.toggleFavorite(for: article)
        NotificationCenter.default.post(name: .notificationFavorite, object: self.searchViewModel.searchResults[fIndex])
        NotificationCenter.default.post(name: .notificationNews, object: self.searchViewModel.searchResults[fIndex])
        
        print("Favori Haberler: \(searchViewModel.favoriteArticles.count)")
    }
}
extension SearchViewController : SearchViewModelDelegate {
    func reloadData() {
        self.searchTableView.reloadData()
    }
}
