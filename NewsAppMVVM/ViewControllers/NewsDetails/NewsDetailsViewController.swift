//
//  NewsDetailsViewController.swift
//  NewsApp
//
//  Created by sude on 23.07.2024.
//

import UIKit

class NewsDetailsViewController: UIViewController {
    var articleURL: URL?
    @IBOutlet weak var webView: UIWebView!
    @IBAction func clickedButtton(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        if let url = articleURL{
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        } else {
            let alert  = UIAlertController(title: "ERROR", message: "URL?", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okButton)
            present(alert, animated: true)
        }
    }
}
