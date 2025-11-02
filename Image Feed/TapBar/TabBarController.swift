import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        print("TapBar")
        super.awakeFromNib()
        let storyboard = UIStoryboard(name:"Main", bundle:.main)
        
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController")
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(systemName: "tab_profile_active"),
            selectedImage: nil
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
        }
}
