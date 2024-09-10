

import UIKit
import SDWebImage

extension Notification.Name {
    static let notificationNews = Notification.Name(rawValue: "NotificationNews")
}

protocol UIScrollViewScrollToTop{
    func scrollToTop()
}

extension NewsViewController: UIScrollViewScrollToTop{
    func scrollToTop(){
        if !viewModel.articles.isEmpty{
            let indexPath  = IndexPath(row: 0, section: 0)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NewsHeaderDelegate, CustomTableViewCellDelegate, UITabBarControllerDelegate{

    @IBOutlet var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var isLoading: Bool = false {
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var refreshControl: UIRefreshControl!
    private let viewModel = NewsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotifications()
        setupTableView()
        setupViewModel()
        setupNavigationBar()
        setupRefreshControl()
        setupTabBarImages()
    }
    
    private func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: viewModel.cellNibName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: viewModel.cellNibName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        
        let headerNib = UINib(nibName: viewModel.headerNibName, bundle: nil)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier:viewModel.headerNibName)
        
    }
    
    private func setupNavigationBar(){
        navigationItem.title = viewModel.title
    }
    
    private func setupNotifications(){
        let notificationCenter: NotificationCenter = NotificationCenter.default
        
       notificationCenter.addObserver(self, selector: #selector(self.updateNews), name: .notificationNews, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.updateFavorite(notification:)), name: .notificationFavorite, object: nil)
        notificationCenter.addObserver(self, selector:
            #selector(self.updateFavorite(notification:)), name: .notificationSearch, object: nil)
     
    }
 
    
    private func setupRefreshControl(){
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupTabBarImages(){
        if let tabBarController = self.tabBarController{
            UITabBarImage.tabBarImages(for: tabBarController)
        }
    }
    
    private func setupViewModel(){
        viewModel.delegate = self
        fetchNews(category: viewModel.selectedCategory,page: viewModel.currentPage)
        viewModel.loadFavorites()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 0, let navController = viewController as? UINavigationController {
            navController.popToRootViewController(animated: true)
            if let topVC = navController.topViewController as? UIScrollViewScrollToTop {
                topVC.scrollToTop()
            }
        }
    }

    @objc func refreshData(){
        if refreshControl.endEditing(false){
            viewModel.currentPage = 1
            fetchNews(category: viewModel.selectedCategory,page: viewModel.currentPage,showLoadingIndicator: false, isRefreshControl: true)
        }
    }
    
    @objc func updateFavorite(notification: Notification){
       guard let updatedArticle = notification.object as? Article else { return }
        if let index = viewModel.favoriteArticles.firstIndex(where: { $0.key == updatedArticle.key }) {
            viewModel.favoriteArticles[index].isFavorited = updatedArticle.isFavorited
        }
        tableView.reloadData()
    }
        
    @objc func updateNews(){
        DispatchQueue.main.async{
            self.viewModel.loadFavorites()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNewsDetailsVC" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedArticle = viewModel.articles[indexPath.row]
                let destinationVC = segue.destination as! NewsDetailsViewController
                if let urlString = selectedArticle.url, let url = URL(string: urlString) {
                    destinationVC.articleURL = url
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toNewsDetailsVC", sender: self)
        
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "NewsHeader") as? NewsHeader else {
            fatalError("Could not load NewsHeader")
        }
        header.categories = self.viewModel.categories
        header.delegate = self
        header.collectionView.reloadData()
        header.isLoading = isLoading
        return header
    }
    
    func didSelectCategory(category: String) {
        if isLoading == false {
            debugPrint("category_test1", isLoading)
            if viewModel.selectedCategory == category {
                tableView.isHidden = false
            }
            else{
                viewModel.selectedCategory = category
                viewModel.currentPage = 1
                fetchNews(category: category, page: viewModel.currentPage, showLoadingIndicator: true)
            }
        }
    }
    
    func fetchNews(category: String ,page: Int, showLoadingIndicator: Bool = true, isRefreshControl: Bool = false) {
        isLoading = true
        if showLoadingIndicator {
            debugPrint("Girdi")
            loadingActivityIndicator.isHidden = false
            loadingActivityIndicator.startAnimating()
        }
        if page == 1 && !isRefreshControl {
            DispatchQueue.main.async{
                self.viewModel.articles.removeAll()
                self.tableView.reloadData()
            }
        }
        viewModel.fetchNews(category: category, page: page) {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            self.loadingActivityIndicator.stopAnimating()
            self.isLoading = false
            debugPrint("category_test3",self.isLoading)
            self.viewModel.isFetching = false
        }
        return
    }
    
    func loadMoreItemsForList(){
        viewModel.currentPage += 1
        fetchNews(category: viewModel.selectedCategory, page: viewModel.currentPage, showLoadingIndicator: false)

       }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !viewModel.isFetching){
                self.viewModel.isFetching = true
                self.loadMoreItemsForList()
            }
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.cellNibName, for: indexPath) as! CustomTableViewCell
        let article = viewModel.articles[indexPath.row]
        cell.article = article
        cell.setUI()
        cell.delegate = self
        return cell
    }
    
    func didTapFavoriteButton(on cell: CustomTableViewCell) {
        guard let article = cell.article, let fIndex = self.viewModel.articles.firstIndex(where: {$0.url == article.url}) else { return }
           viewModel.toggleFavorite(for: article)
        NotificationCenter.default.post(name: .notificationFavorite, object: self.viewModel.articles[fIndex])
        NotificationCenter.default.post(name: .notificationSearch, object: self.viewModel.articles[fIndex])
    
        print("Favori Haberler: \(viewModel.favoriteArticles.count)")
    }
}
extension NewsViewController : NewsViewModelDelegate {
    func reloadData() {
        self.tableView.reloadData()
    }
}
