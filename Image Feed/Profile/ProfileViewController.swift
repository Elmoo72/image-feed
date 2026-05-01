import UIKit
import Kingfisher
import Foundation

final class ProfileViewController: UIViewController {
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage.shared
    
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let profileImageView = UIImageView()
    private let exitButton = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        nameLabel.accessibilityIdentifier = "user name"
        loginNameLabel.accessibilityIdentifier = "user login"
        descriptionLabel.accessibilityIdentifier = "user bio"
        exitButton.accessibilityIdentifier = "logout button"
        
        fetchProfile()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName:ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else {return}
                self.updateAvatar()
            }
        updateAvatar()
        
        setupUI()
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let imageUrl = URL(string: profileImageURL)
        else { return }
        
        print("imageUrl: \(imageUrl)")
        
        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        let processor = RoundCornerImageProcessor(cornerRadius: 20)
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(
            with: imageUrl,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ]) { result in
                
                switch result {
                    
                case .success(let value):
                    print(value.image)
                    print(value.cacheType)
                    print(value.source)
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    private func fetchProfile() {
        guard let token = storage.token else {
            assertionFailure("No user token.")
            return
        }
        
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let profile):
                self?.updateProfileDetails(with: profile)
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
            case .failure(let error):
                print("Error loading profile: \(error)")
            }
        }
        
    }
    
    private func updateProfileDetails(with profile: Profile) {
        print("updateProfileDetails called with name: \(profile.name)")
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }

        private func showLogoutAlert() {
            let alert = UIAlertController(
                title: "Пока, пока!",
                message: "Уверены, что хотите выйти?",
                preferredStyle: .alert
            )
            
            let logoutAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
                ProfileLogoutService.shared.logout()
            }
            
            let cancelAction = UIAlertAction(title: "Нет", style: .cancel)
            
            alert.addAction(logoutAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true)
        }
        
        @objc private func didTapLogoutButton() {
            print("кнопка нажата")
            showLogoutAlert()
        }
    
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "YP-Black")
        
        print("»>\(String(describing: profileService.profile))")
        profileImageView.image = UIImage(named: "ProfileImage")
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.textColor = .white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        loginNameLabel.textColor = .gray
        loginNameLabel.font = UIFont.systemFont(ofSize: 13)
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        exitButton.setImage(UIImage(named: "Exit"), for: .normal)
        exitButton.tintColor = .red
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.isUserInteractionEnabled = true
        exitButton.isEnabled = true
        exitButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            loginNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            exitButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            exitButton.heightAnchor.constraint(equalToConstant: 44),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
        ])
    }
}

