//
//  LoginTableViewCell.swift
//  NewsApp1
//
//  Created by sude on 28.08.2024.
//

import UIKit
protocol LoginTableViewCellDelegate: AnyObject{
    func loginButtonClicked(email: String,password: String)
    func navigateToRegister()
    func makeAlert(titleInput: String, messageInput: String)
    func startActivityIndicator()
    func stopActivityIndicator()
}

class LoginTableViewCell: UITableViewCell {
    weak var delegate: LoginTableViewCellDelegate?
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var emailText: UITextField!
    @IBOutlet var emailTextView: UIView!
    @IBOutlet var passwordTextView: UIView!
    @IBOutlet var passwordText: UITextField!
    @IBOutlet var togglePasswordButton: UIButton!
    @IBAction func togglePasswordVisibility(_ sender: Any) {
        isPasswordVisible.toggle()
        passwordText.isSecureTextEntry = !isPasswordVisible
        let buttonImageName = isPasswordVisible ? "eye.fill" : "eye.slash.fill"
        togglePasswordButton.setImage(UIImage(systemName: buttonImageName), for: .normal)
          
    }
    
    var isPasswordVisible: Bool = false
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTextViewStyle(view: emailTextView)
        setupTextViewStyle(view: passwordTextView)
        
        passwordText.isSecureTextEntry = true
        togglePasswordButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        togglePasswordButton.tintColor = .gray
        
        loadingActivityIndicator.isHidden = true
        loadingActivityIndicator.hidesWhenStopped = true
    }
    private func setupTextViewStyle(view: UIView){
        view.layer.masksToBounds = true
        view.layer.borderWidth = 2.0
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 6
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
   
    @IBAction func signInClicked(_ sender: Any) {
        delegate?.navigateToRegister()
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        if let email = emailText.text , let password = passwordText.text , !email.isEmpty, !password.isEmpty{
            loginButton.isEnabled = false
            loadingActivityIndicator.isHidden = false
            delegate?.startActivityIndicator()
            delegate?.loginButtonClicked(email: email, password: password)
        }else {
            delegate?.makeAlert(titleInput: "Error", messageInput: "Lütfen tüm alanları doldurunuz!")
        }
    }
}
