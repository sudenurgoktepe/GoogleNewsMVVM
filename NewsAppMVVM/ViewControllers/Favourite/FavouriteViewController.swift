import UIKit
import FirebaseFirestore
import FirebaseAuth

extension Notification.Name {
    static let notificationFavorite = Notification.Name(rawValue: "NotificationFavorite")
}

extension FavouriteViewController: UIScrollViewScrollToTop {
    func scrollToTop() {
        if !favoriteViewModel.favoriteArticles.isEmpty{
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}

class FavouriteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomTableViewCellDelegate,UITabBarControllerDelegate {
    private let favoriteViewModel = FavouriteViewModel()
    @IBOutlet var tableView: UITableView!
    @IBOutlet var favoriLabel: UILabel!
   
    @IBAction func logOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "toLOG", sender: nil )
        } catch let signOutError as NSError{
            print("Error signing out: %@", signOutError)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotifications()
        setupTableView()
        setupNavigationBar()
        setupFavouriteViewModel()

    }
    
    private func setupTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        
        let nib = UINib(nibName: favoriteViewModel.nibName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: favoriteViewModel.nibName)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        
    }
    
    private func setupNavigationBar(){
        navigationItem.title = favoriteViewModel.title
    }
    
    private func setupNotifications(){
        let notificationCenter: NotificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.loadFav), name: .notificationFavorite, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.updateFavorite(notification:)), name: .notificationFavorite, object: nil)
    }
    
    private func setupFavouriteViewModel(){
        favoriteViewModel.delegate = self
        favoriteViewModel.loadFavorites()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.delegate = self
    }
        
    @objc func loadFav(){
        favoriteViewModel.loadFavorites()
        self.updateFavorite()
    }
    
    @objc func updateFavorite(notification: Notification){
        guard let updatedArticle = notification.object as? Article else { return}
        if let fIndex = self.favoriteViewModel.favoriteArticles.firstIndex(where: {$0.url == updatedArticle.url}){
            self.favoriteViewModel.favoriteArticles[fIndex].isFavorited?.toggle()
            debugPrint("Toggle etti fav")
        }
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNewsDetailsVC" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedArticle = favoriteViewModel.favoriteArticles[indexPath.row]
                let destinationVC = segue.destination as! NewsDetailsViewController
                if let urlString = selectedArticle.url, let url = URL(string: urlString) {
                    destinationVC.articleURL = url
                }
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 2, let navController = viewController as? UINavigationController {
            navController.popToRootViewController(animated: true)
            if let topVC = navController.topViewController as? UIScrollViewScrollToTop {
                topVC.scrollToTop()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toNewsDetailsVC", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteViewModel.favoriteArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: favoriteViewModel.nibName, for: indexPath) as! CustomTableViewCell
        let article = favoriteViewModel.favoriteArticles[indexPath.row]
        cell.article = article
        cell.setUI()
        cell.delegate = self
        cell.FavouriteButton.setImage(UIImage(named:"Vector1" ), for:.normal)
        return cell
    }
    
    func updateFavorite(){
        if self.favoriteViewModel.favoriteArticles.count == 0 {
            self.favoriLabel.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.favoriLabel.isHidden = true
            self.tableView.isHidden = false
        }
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }
    
    func didTapFavoriteButton(on cell: CustomTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
  
        favoriteViewModel.toggleFavorite(at: indexPath)
    }
}

extension FavouriteViewController : FavouriteViewModelDelegate {
    func reloadData() {
        self.tableView.reloadData()
    }
}

