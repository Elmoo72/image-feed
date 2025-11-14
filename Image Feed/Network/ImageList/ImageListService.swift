import Foundation
import UIKit
import WebKit

struct Photo{
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Codable {
    let id: String
    let createdAt: String?
    let width: Int?
    let height: Int?
    let likes: Int?
    let likedByUser: Bool?
    let description: String?
    let urls: UrlsResult?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case likes
        case likedByUser = "liked_by_user"
        case description
        case urls
    }
}

struct UrlsResult: Codable {
    let raw: String?
    let full: String?
    let regular: String?
    let small: String?
    let thumb: String?
}


final class ImageListService {
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    
    static let shared = ImageListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImageListServiceDidChange")
    private init() {}
    
    func cleanData(){
        photos = []
        lastLoadedPage = nil
        task?.cancel()
        task = nil
    }
    
    func fetchPhotosNextPage(){
        task?.cancel()
        guard let token = OAuth2TokenStorage.shared.token else {
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let request = makePhotoListRequest(page:nextPage, token: token) else {
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
                   guard let self else { return }
                   
                   switch result {
                   case .success(let photoResults):
                       let dateFormatter = ISO8601DateFormatter()
                       
                       let newPhotos: [Photo] = photoResults.map {
                           Photo(
                               id: $0.id,
                               size: CGSize(width: $0.width ?? 0, height: $0.height ?? 0),
                               createdAt: $0.createdAt.flatMap { dateFormatter.date(from: $0) },
                               welcomeDescription: $0.description,
                               thumbImageURL: $0.urls?.thumb ?? "",
                               largeImageURL: $0.urls?.full ?? "",
                               isLiked: $0.likedByUser ?? false
                           )
                       }
                       
                       DispatchQueue.main.async {
                           self.photos.append(contentsOf: newPhotos)
                           self.lastLoadedPage = nextPage
                           
                           NotificationCenter.default.post(
                               name: ImageListService.didChangeNotification,
                               object: self,
                               userInfo: ["photos": self.photos]
                           )
                       }
                       
                   case .failure(let error):
                       print("Ошибка загрузки фото: \(error.localizedDescription)")
                   }
               }
               
               self.task = task
               task.resume()
           }
                func tableView(
                    _ tableView: UITableView,
                    willDisplay cell: UITableViewCell,
                    forRowAt indexPath: IndexPath
                ){
                    
                }
                
    private func makePhotoListRequest(page: Int, token: String) -> URLRequest? {
        guard let url = URL(string:"https://api.unsplash.com/photos?page=\(page)&per_page=10") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                return request
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
           task?.cancel()
           guard let token = OAuth2TokenStorage.shared.token else {
               return
           }
           
           let method = isLike ? "POST" : "DELETE"
           guard let request = makeLikeRequest(photoId: photoId, method: method, token: token) else {
               return
           }
           
           let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
               if let error = error {
                   DispatchQueue.main.async {
                       completion(.failure(error))
                   }
                   return
               }
               
               guard let httpResponse = response as? HTTPURLResponse,
                     (200...299).contains(httpResponse.statusCode) else {
                   DispatchQueue.main.async {
                       completion(.failure(URLError(.badServerResponse)))
                   }
                   return
               }
               
               DispatchQueue.main.async {
                   if let index = self?.photos.firstIndex(where: { $0.id == photoId }) {
                       let photo = self?.photos[index]
                       let newPhoto = Photo(
                           id: photoId,
                           size: photo?.size ?? CGSize.zero,
                           createdAt: photo?.createdAt,
                           welcomeDescription: photo?.welcomeDescription,
                           thumbImageURL: photo?.thumbImageURL ?? "",
                           largeImageURL: photo?.largeImageURL ?? "",
                           isLiked: !(photo?.isLiked ?? false)
                       )
                       self?.photos[index] = newPhoto
                       
                       NotificationCenter.default.post(
                           name: ImageListService.didChangeNotification,
                           object: self,
                           userInfo: ["photos": self?.photos ?? []]
                       )
                   }
                   completion(.success(()))
               }
           }
           
           self.task = task
           task.resume()
       }
       
       private func makeLikeRequest(photoId: String, method: String, token: String) -> URLRequest? {
           guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
               return nil
           }
           
           var request = URLRequest(url: url)
           request.httpMethod = method
           request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
           return request
       }
   }

        
