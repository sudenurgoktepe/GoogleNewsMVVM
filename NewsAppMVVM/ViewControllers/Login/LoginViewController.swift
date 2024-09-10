//
//  LoginViewController.swift
//  NewsApp1
//
//  Created by sude on 26.08.2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,LoginTableViewCellDelegate{
    @IBOutlet var loginTableView: UITableView!
    var favoriteArticles: [Article] = []
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "NEWS"
        loginTableView.delegate = self
        loginTableView.dataSource = self
        loginTableView.register(UINib(nibName: "LoginTableViewCell", bundle: nil), forCellReuseIdentifier: "LoginTableViewCell")

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
               view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func firestoreDatabase() async{
        guard let userID =  Auth.auth().currentUser?.uid else {
            return
        }
        do {
            let snapshot = try await db.collection("users").document(userID).collection("favorites").getDocuments()
        } catch {
            print("Error writing document: \(error)")
        }
    }
    
      func handleError(_ error: Error) {
        let nsError = error as NSError
          guard let cell = loginTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? LoginTableViewCell else { return }
             cell.loginButton.isEnabled = true
             cell.loadingActivityIndicator.stopAnimating()
          if let errorCode = AuthErrorCode(rawValue: nsError.code) {
              let errorMessage: String
              switch errorCode {
              case .invalidEmail:
                  errorMessage = "Lütfen geçerli bir e-posta girin."
                  cell.emailTextView.layer.borderColor = UIColor.red.cgColor
                  cell.emailTextView.layer.borderWidth = 2.0
              case .wrongPassword:
                  errorMessage = "Şifreniz yanlış. Lütfen tekrar deneyin."
                  cell.passwordTextView.layer.borderColor = UIColor.red.cgColor
                  cell.passwordTextView.layer.borderWidth = 2.0
              case .userNotFound:
                  errorMessage = "Belirtilen kullanıcı için hesap bulunamadı. Lütfen kontrol edip tekrar deneyin."
                  cell.emailTextView.layer.borderColor = UIColor.red.cgColor
                  cell.emailTextView.layer.borderWidth = 2.0
              case .emailAlreadyInUse:
                  errorMessage = "E-posta zaten başka bir hesapla kullanılıyor."
                  cell.emailTextView.layer.borderColor = UIColor.red.cgColor
                  cell.emailTextView.layer.borderWidth = 2.0
              case .userDisabled:
                  errorMessage = "Hesabınız devre dışı bırakıldı. Lütfen desteğe başvurun."
              case .networkError:
                  errorMessage = "Ağ hatası. Lütfen tekrar deneyin."
              case .invalidCredential:
                  errorMessage = "Geçersiz kimlik bilgisi. Lütfen bilgilerinizi kontrol edin ve tekrar deneyin."
              default:
                  errorMessage = "Bilinmeyen bir hata oluştu. Lütfen tekrar deneyin."
              }
              makeAlert(titleInput: "Error", messageInput: errorMessage)
          }else {
            makeAlert(titleInput: "Error", messageInput: "Bilinmeyen bir hata oluştu. Lütfen tekrar deneyin.")
        }
    }

    func loginButtonClicked(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authData, error in
            if let error = error {
                self.handleError(error) 
                self.stopActivityIndicator()
            } else {
                Task {
                    await self.firestoreDatabase()
                }
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "Main")
                self.present(vc, animated: true, completion:{
                self.stopActivityIndicator()
                guard let cell = self.loginTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? LoginTableViewCell else { return }
                    cell.loginButton.isEnabled = true
                })
            }
        }
    }

    func navigateToRegister() {
        let storyboard: UIStoryboard = UIStoryboard(name:"Register" , bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "Register")
        self.present(vc, animated: true,completion: nil)
    }
    
    func makeAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func startActivityIndicator() {
        DispatchQueue.main.async {
            if let cell = self.loginTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? LoginTableViewCell {
                cell.loadingActivityIndicator.startAnimating()
            }
        }
    }
       
    func stopActivityIndicator() {
        DispatchQueue.main.async {
            if let cell = self.loginTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? LoginTableViewCell {
                cell.loadingActivityIndicator.stopAnimating()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LoginTableViewCell", for: indexPath) as! LoginTableViewCell
        cell.delegate = self
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = selectedBackgroundView
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350.0
    }
}
