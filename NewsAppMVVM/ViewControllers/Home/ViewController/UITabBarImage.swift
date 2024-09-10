import UIKit

class UITabBarImage {
    static func tabBarImages(for tabBarController: UITabBarController) {
        if let homeTabBarItem = tabBarController.tabBar.items?[0] {
            let homeImage = UIImage(named: "home")?.withRenderingMode(.alwaysOriginal)
            let homeSelectedImage = UIImage(named: "home1")?.withRenderingMode(.alwaysOriginal)
            homeTabBarItem.image = homeImage
            homeTabBarItem.selectedImage = homeSelectedImage
        }

        if let searchTabBarItem = tabBarController.tabBar.items?[1] {
            let searchImage = UIImage(named: "search")?.withRenderingMode(.alwaysOriginal)
            let searchSelectedImage = UIImage(named: "search1")?.withRenderingMode(.alwaysOriginal)
            searchTabBarItem.image = searchImage
            searchTabBarItem.selectedImage = searchSelectedImage
        }

        if let favTabBarItem = tabBarController.tabBar.items?[2] {
            let favImage = UIImage(named: "favori")?.withRenderingMode(.alwaysOriginal)
            let favSelectedImage = UIImage(named: "favori1")?.withRenderingMode(.alwaysOriginal)
            favTabBarItem.image = favImage
            favTabBarItem.selectedImage = favSelectedImage
        }
    }
}
