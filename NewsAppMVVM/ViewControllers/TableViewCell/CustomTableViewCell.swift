import UIKit

protocol CustomTableViewCellDelegate: AnyObject {
    func didTapFavoriteButton(on cell: CustomTableViewCell)
}

class CustomTableViewCell: UITableViewCell {
    @IBOutlet var FavouriteButton: UIButton!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var imageView1: UIImageView!
    @IBOutlet var label1: UILabel!
    @IBOutlet var label3: UILabel!
    @IBOutlet var label2: UILabel!
    
    var article : Article?
    weak var delegate: CustomTableViewCellDelegate?
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBAction func clickedFavouriteButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        delegate?.didTapFavoriteButton(on: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label1.numberOfLines = 0
        label2.numberOfLines = 0
        label3.numberOfLines = 0
        imageView1.layer.cornerRadius = 8
        imageView1.clipsToBounds = true
        
        label2.font = UIFont.systemFont(ofSize: 18)
        label3.font = UIFont.systemFont(ofSize: 15)
        label1.font = UIFont.systemFont(ofSize: 15)
        label3.font = UIFont(name: "Helvetica Neue", size: 16)
        
        setLineSpacing(for: label1, lineSpacing: 5)
        setLineSpacing(for: label2, lineSpacing: 5)
        setLineSpacing(for: label3, lineSpacing: 5)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setLineSpacing(for label: UILabel, lineSpacing: CGFloat) {
        guard let text = label.text else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        label.attributedText = attributedString
    }
    
    func setUI() {
        guard let article else { return }
        self.label1.text = article.source
        self.label2.text = article.name
        self.label3.text = article.description
        
        if let imageURL = URL(string: article.image ?? "") {
            activityIndicator.startAnimating()
            imageView1.sd_setImage(with: imageURL){ [weak self](image,error,cacheType,url)  in
                self?.activityIndicator.stopAnimating()
                if let error = error {
                    print(error)
                    self?.imageView1.image = UIImage(named: "notfound")
                } else if image != nil  {
                    self?.imageView1.image = image
                } else {
                    self?.imageView1.image = UIImage(named: "notfound")
                }
            }
        } else {
                imageView1.image = UIImage(named: "notfound")
                activityIndicator.stopAnimating()
                
            }
        
        let isFavorite = article.isFavorited ?? false
        let imageName = isFavorite ? "Vector1" : "Vector"
        FavouriteButton.setImage(UIImage(named: imageName), for: .normal)
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = .systemGray6
        self.selectedBackgroundView = selectedBackgroundView
        
        print(isFavorite ? "Favori kaldırıldı" : "Favori eklendi")
        print("Image Name: \(imageName)")
    }
}
