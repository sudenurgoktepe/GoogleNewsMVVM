import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol FavouriteViewModelDelegate : AnyObject {
    func reloadData()
    func updateFavorite()
}
// test
final class FavouriteViewModel{
    var favoriteArticles: [Article] = []
    var nibName = "CustomTableViewCell"
    var title = "Favorites"
    var article: [Article] = []
    weak var delegate: FavouriteViewModelDelegate?
    let db = Firestore.firestore()
    func loadFavorites() {
        getAllFirestoreSavedFavorites()
    }
    func addFavoriteToFirestore(favoriteId: String) {
        let authId = Auth.auth().currentUser?.uid
        db.collection("users").document("favorites").collection(authId ?? "").addDocument(data: ["favoriteId": favoriteId])
    }
    
    func getAllFirestoreSavedFavorites() {
        guard let authId = Auth.auth().currentUser?.uid else { return }
        self.favoriteArticles.removeAll()
        db.collection("users").document("favorites").collection(authId).getDocuments { querySnapshot, err in
            
            querySnapshot?.documents.forEach({ document in
                let key = document["key"] as? String
                let url = document["url"] as? String
                let description = document["description"] as? String
                let image = document["image"] as? String
                let name = document["name"] as? String
                let source = document["source"] as? String
                
                let newArticle = Article(key: key ?? "", url: url ?? "", description: description ?? "", image: image ?? "", name: name ?? "", source: source ?? "", isFavorited: true)
                self.favoriteArticles.append(newArticle)
            })
            self.delegate?.updateFavorite()
            self.delegate?.reloadData()
        }
    }
    
    func deleteFromFirestore(url: String) {
        guard let authId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document("favorites").collection(authId).whereField("url", isEqualTo: url).getDocuments { querySnapshot, err in
            for document in querySnapshot!.documents {
                document.reference.delete { _ in
                    NotificationCenter.default.post(name: .notificationNews, object: nil)
                    NotificationCenter.default.post(name: .notificationSearch, object: nil)
                }
            }
        }
    }
  
    func toggleFavorite(at indexPath: IndexPath) {
        let article = favoriteArticles[indexPath.row]
        favoriteArticles.removeAll { $0.url == article.url }
        deleteFromFirestore(url: article.url ?? "")
        delegate?.updateFavorite()
        delegate?.reloadData()
    }
}
