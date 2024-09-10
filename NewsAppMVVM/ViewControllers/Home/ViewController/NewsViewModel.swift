//
//  NewsViewModel.swift
//  NewsApp1
//
//  Created by sude on 20.08.2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol NewsViewModelDelegate : AnyObject {
    func reloadData()
}

final class NewsViewModel{
    var title = "Google News"
    var headerNibName = "NewsHeader"
    var cellNibName = "CustomTableViewCell"
    var articles: [Article] = []
    var isFetching: Bool = false
    var currentPage: Int = 1
    var isloading: Bool = false
    let db = Firestore.firestore()
   

    var favoriteArticles: [Article] = []  {
        didSet {
            self.delegate?.reloadData()
        }
    }
    
    let categories = ["general", "entertainment", "health", "economy", "technology"]
    var selectedCategory: String = "general"
    
    weak var delegate: NewsViewModelDelegate?
    
    func fetchNews(category: String,page:Int, completion: @escaping () -> Void) {
        let keyURL = "https://api.collectapi.com/news/getNews?country=tr&tag="
        let urlString = keyURL + category
        guard let url = URL(string: urlString) else {
            print("Geçersiz url\(urlString)")
            isFetching = false
            completion()
            return
        }
        
        NetworkManager.shared.fetchNews(category: category, page: page) { [weak self] articles in
            guard let self = self else { return }
            guard let articles  = articles else {
                print("veri bulunamadı")
                completion()
                return
            }
            
            self.articles += articles
            for i in 0..<self.articles.count{
                if self.favoriteArticles.contains(where: {$0.url == self.articles[i].url }){
                    self.articles[i].isFavorited = true
                }
                else{
                    self.articles[i].isFavorited = false
                }
            }
            completion()
        }
    }
    
    func deleteFromFirestore(url: String) {
        guard let authId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document("favorites").collection(authId).whereField("url", isEqualTo: url).getDocuments { querySnapshot, err in
            for document in querySnapshot!.documents {
                document.reference.delete { _ in
                    NotificationCenter.default.post(name: .notificationFavorite, object: nil)
                    NotificationCenter.default.post(name: .notificationSearch, object: nil)
                }
            }
        }
    }
    
    func favoritedArticles(){
        for i in 0..<self.articles.count {
            if favoriteArticles.contains (where: { $0.url == self.articles[i].url }) {
                self.articles[i].isFavorited = true
            } else{
                self.articles[i].isFavorited = false
            }
        }
    }
    
    func loadFavorites() {
        getAllFirestoreSavedFavorites()
    }
    
    func toggleFavorite(for article: Article) {
        if let index = articles.firstIndex(where: { $0.url == article.url }) {
            articles[index].isFavorited?.toggle()
            if let isFavorited = articles[index].isFavorited, isFavorited {
                if !favoriteArticles.contains(where: { $0.url == article.url }) {
                    addFavoriteToFirestore(article: articles[index])
                    favoriteArticles.append(articles[index])
                }
            }else {
                favoriteArticles.removeAll { $0.url == article.url }
                deleteFromFirestore(url: article.url ?? "")
            }
            delegate?.reloadData()
        }
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
            self.favoritedArticles()
            self.delegate?.reloadData()
        }
    }
    
    func addFavoriteToFirestore(article: Article){
        guard let authId = Auth.auth().currentUser?.uid else { return }
        let articleData: [String: Any] =  [
            "key" : article.key,
            "url" : article.url ?? "",
            "description" : article.description ?? "",
            "image": article.image ?? "",
            "name" : article.name,
            "source ": article.source,
            "isFavorited": true
        ]
        db.collection("users").document("favorites").collection(authId).addDocument(data: articleData) { err in
            debugPrint(err?.localizedDescription, "eklerken_hata_oldu")
        }
    }
}
