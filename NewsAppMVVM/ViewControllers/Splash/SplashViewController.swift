//
//  SplashViewController.swift
//  NewsApp1
//
//  Created by sude on 20.08.2024.
//

import UIKit
import FirebaseAuth
class SplashViewController: UIViewController {
    @IBOutlet var loadingActivityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingActivityIndicator.startAnimating()
        checkUser()
    }
    
    func checkUser(){
        if Auth.auth().currentUser != nil {
            fetch()
        } else{
            DispatchQueue.main.async{
                self.loadingActivityIndicator.stopAnimating()
                self.performSegue(withIdentifier: "toLoginVC", sender: nil)
            }
        }
    }
    
    func fetch(){
        NetworkManager.shared.fetchNews(category: "general", page: 1) { [weak self] articles in
            guard articles != nil else {
                return
            }
            DispatchQueue.main.async {
                self?.loadingActivityIndicator.stopAnimating()
                if let articles = articles, !articles.isEmpty {
                self?.performSegue(withIdentifier: "toNews", sender: nil)
                } else {
                    self?.errorAlert()
                }
            }
        }
    }
    
    func errorAlert(){
        let alert = UIAlertController(title: "Error", message: "API isteğinin süresi doldu. Daha sonra tekrar deneyin", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                   self.fetch()
        }))
        present(alert, animated: true, completion: nil)
    }
}
