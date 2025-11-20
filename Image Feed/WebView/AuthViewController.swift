import WebKit
import UIKit
import ProgressHUD

class AuthViewController: UIViewController{
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target:nil , action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP-Black")
    }
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        print("AuthVC: got code = \(code)")
        print("AuthVC: start fetchOAuthToken")
        
        ProgressHUD.animate()
        
        OAuth2Service.shared.fetchOAuthToken(code) { [weak self] result in
            DispatchQueue.main.async {
                ProgressHUD.dismiss()
                guard let self = self else { return }
                
                switch result {
                case .success(let token):
                    print("AuthVC: token received: \(token)")
                    OAuth2TokenStorage.shared.token = token
                    // Закрываем WebView и уведомляем делегата
                    vc.dismiss(animated: true) {
                        print("AuthVC: calling delegate.didAuthenticate")
                        self.delegate?.didAuthenticate(self)
                    }
                    
                case .failure(let error):
                    print("OAuth token fetch failed: \(error)")
                    
                    self.showAuthErrorAlert {
                        vc.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

extension AuthViewController {
    func showAuthErrorAlert(completion: (() -> Void)? = nil) {
        print("Алерт показан")
        let alertController = UIAlertController(
            title: "Что то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: "OK",
            style: .default
        ) { _ in
            completion?()
        }
        
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}
