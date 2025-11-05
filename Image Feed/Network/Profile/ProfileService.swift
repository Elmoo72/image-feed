import Foundation

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    
    
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}



final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    
    
    private(set) var profile: Profile?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in switch result {
        case .success(let result):
            print("=== PROFILE DATA DEBUG ===")
            print("username: \(result.username)")
            print("firstName: \(String(describing: result.firstName))")
            print("lastName: \(String(describing: result.lastName))")
            
            
            let displayName: String
            if let firstName = result.firstName, let lastName = result.lastName,
               !firstName.isEmpty, !lastName.isEmpty {
                displayName = "\(firstName) \(lastName)"
            } else if let firstName = result.firstName, !firstName.isEmpty {
                displayName = firstName
            } else if let lastName = result.lastName, !lastName.isEmpty {
                displayName = lastName
            } else {
                displayName = result.username
            }
            
            let profile = Profile(
                username: result.username,
                name:displayName,
                loginName: "@\(result.username)",
                bio: result.bio
            )
            
            self?.profile = profile
            completion(.success(profile))
        case .failure(let error):
            print("[fetchProfile]: Ошибка запроса: \(error.localizedDescription)")
            completion(.failure(error))
        }
            self?.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
