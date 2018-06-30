

import Foundation

typealias JSON = [String: Any]

@objc class NetworkProcessor: NSObject {
    let url: URL

    init(url: URL) {
        self.url = url
    }

    @objc func downloadJSONFromURL(_ completion: @escaping (JSON) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if error == nil {
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        guard let data = data else { return }
                        do {
                            guard let photos = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? JSON else { return }
                            completion(photos)
                        } catch let error {
                            print("Error serializing json:", error)
                        }
                    default:
                        print("HTTP Response Code: \(httpResponse.statusCode)")
                    }
                }
            } else {
                print("Error: \(String(describing: error?.localizedDescription))")
            }
        }.resume()
    }
}
