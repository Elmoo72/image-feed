import WebKit
import UIKit
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

        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
          //  UIBlockingProgressHUD.dismiss()

            switch result {
            case .success(let token):
                print("AuthVC: token received: \(token)")
                OAuth2TokenStorage().token = token

                vc.dismiss(animated: true) {
                    print("AuthVC: calling delegate.didAuthenticate")
                    self.delegate?.didAuthenticate(self)
                }

            case .failure(let error):
                print("OAuth token fetch failed: \(error)")
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}
