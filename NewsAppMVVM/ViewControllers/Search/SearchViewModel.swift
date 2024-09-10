//
//  SearchViewModel.swift
//  NewsApp1
//
//  Created by sude on 21.08.2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol SearchViewModelDelegate : AnyObject{
    func reloadData()
}

final class SearchViewModel{
    var favoriteArticles: [Article] = []
    var searchResults: [Article] = []
    var article: [Article] = []
    var headerNibName = "CustomTableViewCell"
    var searchTitle = "Search"
    weak var delegate: SearchViewModelDelegate?
    let db = Firestore.firestore()
    func fetchNews() {
        NetworkManager.shared.fetchNews(category: "general" , page: 1) { articles in
            if let searchText = articles {
                self.searchResults = searchText
                debugPrint("Search rs geldi")
                for i in 0..<self.searchResults.count {
                    if self.favoriteArticles.contains(where: { $0.url == self.searchResults[i].url }) {
                        self.searchResults[i].isFavorited = true
                    } else {
                        self.searchResults[i].isFavorited = false
                    }
                }
                self.delegate?.reloadData()
            } else {
                self.searchResults = []
                self.delegate?.reloadData()
            }
        }
    }
    
    func loadFavorites() {
        getAllFirestoreSavedFavorites()
    }
    
    func searchFavoritedArticles(){
        for i in 0..<self.searchResults.count {
            if self.favoriteArticles.contains(where: { $0.url == self.searchResults[i].url }) {
                self.searchResults[i].isFavorited = true
            } else {
                self.searchResults[i].isFavorited = false
            }
        }
    }
 
    func deleteFromFirestore(url: String) {
        guard let authId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document("favorites").collection(authId).whereField("url", isEqualTo: url).getDocuments { querySnapshot, err in
            for document in querySnapshot!.documents {
                document.reference.delete { _ in
                    NotificationCenter.default.post(name: .notificationFavorite, object: nil)
                    NotificationCenter.default.post(name: .notificationNews, object: nil)
                }
            }
        }
    }
    
    func toggleFavorite(for article: Article) {
        guard let index = searchResults.firstIndex(where: { $0.url == article.url }) else { return }
        searchResults[index].isFavorited?.toggle()
        
        if searchResults[index].isFavorited == true {
            if !favoriteArticles.contains(where: { $0.url == searchResults[index].url }) {
                favoriteArticles.append(searchResults[index])
                addFavoriteToFirestore(article: searchResults[index])
            }
        } else {
            favoriteArticles.removeAll { $0.url == searchResults[index].url }
            deleteFromFirestore(url: article.url ?? "")

        }
        self.delegate?.reloadData()
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
            self.searchFavoritedArticles()
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


