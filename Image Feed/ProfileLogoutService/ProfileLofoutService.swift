import Foundation
import WebKit
import UIKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
   
    private init() { }

    func logout() {
        cleanCookies()
        cleanToken()
        cleanServicesData()
        switchToSplashScreen()
    }

    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanToken() {
        OAuth2TokenStorage.shared.token = nil
    }
    
    private func cleanServicesData() {
        ProfileService.shared.cleanData()
        ProfileImageService.shared.cleanData()
        ImageListService.shared.cleanData()
    }
    
    private func switchToSplashScreen() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("Invalid window configuration")
                return
            }
            
            let splashViewController = SplashViewController()
            window.rootViewController = splashViewController
        }
    }
}
