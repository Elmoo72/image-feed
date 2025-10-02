import WebKit
import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private init() { }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "unsplash.com"
        urlComponents.path = "/oauth/token"
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let request = makeOAuthTokenRequest(code: code) else{
            print(" Ошибка: не удалось создать URLRequest для OAuth-токена")
         return }
        
        let tokenStorage = OAuth2TokenStorage()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Сетевая ошибка: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                
                if let httpResponse = response as? HTTPURLResponse {
                       print(" Ошибка от сервиса Unsplash: код ответа \(httpResponse.statusCode)")
                   } else {
                       print(" Ошибка: response не является HTTPURLResponse или данные отсутствуют")
                   }
                DispatchQueue.main.async { completion(.failure(NSError())) }
                return
            }
            
            do {
                let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                tokenStorage.token = tokenResponse.accessToken
                DispatchQueue.main.async { completion(.success(tokenResponse.accessToken)) }
            } catch {
                print(" Ошибка декодирования OAuthTokenResponseBody: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
        
        task.resume()
    }
}
