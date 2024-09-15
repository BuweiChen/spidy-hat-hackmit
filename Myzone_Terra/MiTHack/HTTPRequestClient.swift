//
//  HTTPRequestClient.swift
//  MiTHack
//
//  Created by Elliott Yu on 10/09/2024.
//

import Foundation

struct BlankResponse: Codable{
    let status: String?
}

/**
 A client for HTTP Requests. If not sure how to use, please read the WIKI: https://github.com/tryterra/TerraiOSPackage/wiki/SDK-Internal-Guide
 **/
class HTTPRequestClient<T: Codable>{
    

    let builder: Builder
    
    let queue = DispatchQueue(label: "co.tryterra.http.requests.\(UUID().uuidString)")
    
    init(_ builder: Builder){
        self.builder = builder
    }
    
    class Builder{
        var method: String = "GET"
        var url: String?
        var headers: [String: String] = [:]
        var input: T.Type? = nil
        var output: String? = nil
        
        enum HTTPMethods{
            case POST, GET, DELETE
        }
        
        func setMethod(_ method: HTTPMethods) -> Builder{
            switch(method){
            case .GET:
                self.method = "GET"
            case .POST:
                self.method = "POST"
            case .DELETE:
                self.method = "DELETE"
            }
            return self
        }
        
        func setUrl(_ url: String) -> Builder{
            self.url = url
            return self
        }
        
        func setHeaders(_ headers: [String: String]) -> Builder{
            self.headers = headers
            return self
        }
        
        func withInput(_ decodeType: T.Type) -> Builder{
            self.input = decodeType
            return self
        }
        
        func withOutput(_ dataToPost: String) -> Builder{
            self.output = dataToPost
            return self
        }
        
        func build() -> HTTPRequestClient{
            return HTTPRequestClient(self)
        }
    }
    
    
    private func makeRequest(completion: @escaping (T?) -> Void){
        let url = URL(string: self.builder.url!)
        guard let requestUrl = url else{
            completion(nil)
            return
        }
        
        var request = URLRequest(url: requestUrl)
        
        request.httpMethod = self.builder.method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        for entry in self.builder.headers{
            request.setValue(entry.value, forHTTPHeaderField: entry.key)
        }
        
        if let dataToPost = self.builder.output{
            request.httpBody = dataToPost.data(using: String.Encoding.utf8)
        }
        
        let task = URLSession.shared.dataTask(with: request){(data, response, error) in
            if let data = data, let responseType = self.builder.input{
                let decoder = JSONDecoder()
                do{
                    let result = try decoder.decode(responseType, from: data)
                    completion(result)
                }
                catch{
                    completion(nil)
                }
            }
            else{
                completion(nil)
            }
        }
        task.resume()
    }
    
    
    func executeRequest(){
        self.makeRequest(completion: {_ in })
    }
    
    func executeAndGetResult(completion: @escaping (T?) -> Void){
        self.makeRequest(completion: completion)
    }
    
    func executeAndGetResultInOuterQueue(completion: @escaping(T?) -> Void){
        self.makeRequest(completion: completion)
    }
    
    func executeAndReturnSynchronousResult() -> T?{
        var result: T? = nil
        
        self.queue.asyncAndWait(execute: DispatchWorkItem(block: {
            self.makeRequest{ data in
                result = data
            }
        }))
        
        return result
    }
}
