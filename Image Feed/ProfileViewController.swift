import UIKit
final class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let NameLabel = UILabel()
        NameLabel.text = "Екатерина Новикова"
        NameLabel.translatesAutoresizingMaskIntoConstraints = false
        NameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        NameLabel.textColor = .white
        
        let TagLabel = UILabel()
        TagLabel.text = "@ekaterina_novikova"
        TagLabel.translatesAutoresizingMaskIntoConstraints = false
        TagLabel.font = UIFont.boldSystemFont(ofSize: 13)
        TagLabel.textColor = .gray
        
        let TextLabel = UILabel()
        TextLabel.text = "Hello, world!"
        TextLabel.translatesAutoresizingMaskIntoConstraints = false
        TextLabel.font = UIFont.boldSystemFont(ofSize: 13)
        TextLabel.textColor = .white
        
        let ProfileImage = UIImageView()
        ProfileImage.image = UIImage(named: "ProfileImage")
        ProfileImage.translatesAutoresizingMaskIntoConstraints = false
        
       let ExitButton = UIButton()
        ExitButton.setImage(UIImage(named: "Exit"), for: .normal)
        ExitButton.tintColor = .red
        ExitButton.translatesAutoresizingMaskIntoConstraints = false

        
        
        
        view.addSubview(ProfileImage)
        view.addSubview(NameLabel)
        view.addSubview(TagLabel)
        view.addSubview(TextLabel)
        view.addSubview(ExitButton)
        
        NSLayoutConstraint.activate([
            ProfileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            ProfileImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            ProfileImage.heightAnchor.constraint(equalToConstant: 70),
            ProfileImage.widthAnchor.constraint(equalToConstant: 70),
            
            NameLabel.topAnchor.constraint(equalTo: ProfileImage.bottomAnchor, constant: 12),
            NameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
          
            
            TagLabel.topAnchor.constraint(equalTo: NameLabel.bottomAnchor, constant: 5),
            TagLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            TextLabel.topAnchor.constraint(equalTo: TagLabel.bottomAnchor, constant: 8),
            TextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            ExitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            ExitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            ExitButton.heightAnchor.constraint(equalToConstant: 44),
            ExitButton.widthAnchor.constraint(equalToConstant: 44),
        ])


        
    }
    
    
}
