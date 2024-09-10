import Foundation
import UIKit

public class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func fetchNews(category: String, page: Int, completion: @escaping ([Article]?) -> Void) {
        let headers = [
            "content-type": "application/json",
            "authorization": "apikey  6yFfE98lKT7c38OizkS6hH:76kdaq0pWLS3Vde8YXV2fP"
        ]
        
        let urlString = "https://api.collectapi.com/news/getNews?country=tr&tag=\(category)&paging=\(page)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }
            do {
                let newsResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(newsResponse.result)
                }
            } catch{
                completion(nil)
            }
        }
        dataTask.resume()
    }
}

