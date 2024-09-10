//
//  RegisterTableViewCell.swift
//  NewsApp1
//
//  Created by sude on 29.08.2024.
//

import UIKit
protocol RegisterTableViewCellDelegate: AnyObject{
    func RegisterButtonClicked(email: String, password: String,firstName: String,lastName: String)
    func navigateToLogin()
    func makeAlert(titleInput:String ,messageInput:String)
}

class RegisterTableViewCell: UITableViewCell {
    weak var delegate: RegisterTableViewCellDelegate?
    var isPasswordVisible: Bool = false
    @IBOutlet var togglePasswordButton: UIButton!
    @IBAction func togglePasswordVisibility(_ sender: Any) {
        isPasswordVisible.toggle()
        passwordText.isSecureTextEntry = !isPasswordVisible
        let buttonImageName = isPasswordVisible ? "eye.fill" : "eye.slash.fill"
        togglePasswordButton.setImage(UIImage(systemName: buttonImageName), for: .normal)
    }
    
    @IBOutlet var passwordTextView: UIView!
    @IBOutlet var emailTextView: UIView!
    @IBOutlet var surnameTextView: UIView!
    @IBOutlet var nameTextView: UIView!
    @IBOutlet var passwordText: UITextField!
    @IBOutlet var emailText: UITextField!
    @IBOutlet var surnameText: UITextField!
    @IBOutlet var nameText: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTextViewStyle(view: nameTextView)
        setupTextViewStyle(view: surnameTextView)
        setupTextViewStyle(view: emailTextView)
        setupTextViewStyle(view: passwordTextView)
        passwordText.isSecureTextEntry = true
        togglePasswordButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        togglePasswordButton.tintColor = .gray
    }
    
    private func setupTextViewStyle(view: UIView){
        view.layer.masksToBounds = true
        view.layer.borderWidth = 2.2
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
  
    @IBAction func signInClicked(_ sender: Any) {
        
        if let email = emailText.text,!email.isEmpty,
           let password = passwordText.text, !password.isEmpty,
           let firstName = nameText.text,!firstName.isEmpty,
           let lastName = surnameText.text ,!lastName.isEmpty{
            delegate?.RegisterButtonClicked(email: email, password: password, firstName: firstName, lastName: lastName)
        } else {
            delegate?.makeAlert(titleInput: "Error", messageInput: "Lütfen tüm alanları doldurunuz!")
            
        }
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        delegate?.navigateToLogin()
    }
}
