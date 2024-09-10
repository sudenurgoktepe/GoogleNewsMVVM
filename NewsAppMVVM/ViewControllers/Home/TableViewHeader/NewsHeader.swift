protocol NewsHeaderDelegate {
    func didSelectCategory(category: String)
    var isLoading: Bool { get }
}

import UIKit


class NewsHeader: UITableViewHeaderFooterView, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    @IBOutlet var collectionView: UICollectionView!
    
    var categories: [String] = []
    var delegate: NewsHeaderDelegate?
    var selectedCategoryIndex: Int = 0
    var isLoading: Bool = false {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let nib = UINib(nibName: "NewsHeaderCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "NewsHeaderCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsHeaderCell", for: indexPath) as! NewsHeaderCell
        cell.label.text = categories[indexPath.item]
        cell.label.text = categories[indexPath.item].uppercased()
        cell.clickedCategory(isSelected: indexPath.item == selectedCategoryIndex)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isLoading {
            return
        }
        selectedCategoryIndex = indexPath.item
        collectionView.reloadData()
        delegate?.didSelectCategory(category: categories[indexPath.item])
        
        collectionView.visibleCells.forEach { cell in
                   if let headerCell = cell as? NewsHeaderCell {
                       let index = collectionView.indexPath(for: headerCell)!.item
                       if isLoading == false{
                           headerCell.clickedCategory(isSelected: index == selectedCategoryIndex)
                       }
                   }
               }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = categories[indexPath.row].uppercased()
        label.sizeToFit()
        return CGSize(width: (label.frame.width+20), height: label.frame.size.height+20)
    }
}











