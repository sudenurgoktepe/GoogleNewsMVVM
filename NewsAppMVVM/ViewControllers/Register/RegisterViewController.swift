//
//  RegisterViewController.swift
//  NewsApp1
//
//  Created by sude on 26.08.2024.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,RegisterTableViewCellDelegate {
    @IBOutlet var registerTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableView.delegate = self
        registerTableView.dataSource = self
        registerTableView.register(UINib(nibName: "RegisterTableViewCell", bundle: nil), forCellReuseIdentifier: "RegisterTableViewCell")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterTableViewCell", for: indexPath) as! RegisterTableViewCell
        cell.delegate = self
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = selectedBackgroundView
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350.0
    }
    
    func RegisterButtonClicked(email: String, password: String ,firstName: String, lastName:String) {
        var isValid = true
        guard let cell = registerTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RegisterTableViewCell else {
            return
        }
        if !isValidName(firstName){
            cell.nameTextView.layer.borderColor = UIColor.red.cgColor
            cell.nameTextView.layer.borderWidth = 2.0
            makeAlert(titleInput: " Error " , messageInput: "İsim en az 3 karakter olmalı")
            isValid = false
        } else {
            cell.nameTextView.layer.borderColor = UIColor.black.cgColor
            cell.nameTextView.layer.borderWidth = 2.0
        }
        if !isValidName(lastName){
            cell.surnameTextView.layer.borderColor = UIColor.red.cgColor
            cell.surnameTextView.layer.borderWidth = 2.0
            makeAlert(titleInput: " Error " , messageInput: "Soyisim en az 3 karakter olmalı")
            isValid = false
        } else{
            cell.surnameTextView.layer.borderColor = UIColor.black.cgColor
            cell.surnameTextView.layer.borderWidth = 2.0
        }
        if !isValidEmail(email){
            cell.emailTextView.layer.borderColor = UIColor.red.cgColor
            cell.emailTextView.layer.borderWidth = 2.0
            makeAlert(titleInput: " Error " , messageInput: "Geçersiz E-posta Adresi")
            isValid = false
        } else{
            cell.emailTextView.layer.borderColor = UIColor.black.cgColor
            cell.emailTextView.layer.borderWidth = 2.0
        }
        if !isValidPassword(password){
            cell.passwordTextView.layer.borderColor = UIColor.red.cgColor
            cell.passwordTextView.layer.borderWidth = 2.0
            makeAlert(titleInput: " Error " , messageInput: "Şifre 1 rakam ve 1 özel karakter dahil en az 6 karakterden oluşmalıdır")
            isValid = false
        } else{
            cell.passwordTextView.layer.borderColor = UIColor.black.cgColor
            cell.passwordTextView.layer.borderWidth = 2.0
        }
        if !isValid {
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { authdata, error in
            if let error = error {
                if (error as NSError).code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    cell.emailTextView.layer.borderColor = UIColor.red.cgColor
                    cell.emailTextView.layer.borderWidth = 2.0
                    self.makeAlert(titleInput: "Error!", messageInput: "E-posta zaten başka bir hesapla kullanılıyor")
                } else {
                    self.makeAlert(titleInput: "Error!", messageInput: error.localizedDescription)
                }
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "Main")
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func navigateToLogin() {
        self.dismiss(animated: true)
        return
        let storyboard: UIStoryboard = UIStoryboard(name:"Login" , bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "Login")
        self.present(vc, animated: true,completion: nil)
    }
    
    func makeAlert(titleInput:String,messageInput:String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert,animated: true,completion:nil )
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$&*]).{6,}$")
        return passwordTest.evaluate(with: password)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func isValidName(_ name: String) -> Bool {
        return name.count >= 3
    }
}
