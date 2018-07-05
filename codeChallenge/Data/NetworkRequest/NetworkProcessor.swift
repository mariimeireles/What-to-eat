

import Foundation

@objc final class NetworkProcessor: NSObject {
    
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    @objc func downloadJSONFromURL(onSucess: @escaping (JSON) -> Void, onError: @escaping (Error) -> Void) {
        let internetHandler = InternetConnectionHandler()
        URLSession.shared.dataTask(with: url) { data, response, error in
            if error == nil {
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else { onError(ServiceError.internalServerError); return
                }
                guard let data = data else { onError(ServiceError.internalServerError); return }
                do {
                    guard let photos = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? JSON else { onError(ServiceError.jsonParse); return }
                    onSucess(photos)
                } catch {
                    onError(ServiceError.jsonParse); return
                }
            } else {
                onError(internetHandler.verifyConnection(error!))
                return
            }
        }.resume()
    }
}
