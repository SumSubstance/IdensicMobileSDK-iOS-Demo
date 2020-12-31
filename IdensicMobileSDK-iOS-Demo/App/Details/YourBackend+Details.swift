//
//  YourBackend+Details.swift
//  IdensicMobileSDK-iOS-Demo
//
//  Created by Sergey Kokunov on 18.06.2020.
//  Copyright © 2020 Sum & Substance. All rights reserved.
//

import Foundation

typealias FlowName = String
typealias AccessToken = String
typealias BearerToken = String

struct Flow: Stringable {
    var name: FlowName
    var isAction: Bool
    var toString: String? { return name }
}

extension YourBackend {
    
    static var bearerToken: BearerToken?
    
    // MARK: - Authorization
    
    static func logIntoSumSubAccount(onComplete: @escaping (Error?) -> Void) {
        
        getBearerToken { (error, bearerToken) in
            self.bearerToken = bearerToken
            onComplete(error)
        }
    }
    
    // MARK: - Required routines
    
    static func getAccessToken(for user: YourUser?, onComplete: @escaping (Error?, AccessToken?) -> Void) {
        
        guard let userId = user?.userId else {
            onComplete(NSError("User is not created yet"), nil)
            return
        }
        
        let path: String
        
        if let externalActionId = user?.externalActionId {
            path = "/resources/accessTokens?userId=\(userId.urlQueryEncoded)&externalActionId=\(externalActionId.urlQueryEncoded)&ttlInSecs=600"
        } else {
            path = "/resources/accessTokens?userId=\(userId.urlQueryEncoded)&ttlInSecs=600"
        }
        
        post(path) { (error, json, statusCode) in
                        
            if let error = error {
                onComplete(error, nil)
            }
            else if let token = json?["token"] as? String {
                onComplete(nil, token)
            }
            else {
                onComplete(NSError("Unable to get access token"), nil)
            }
        }
    }

    // MARK: - SumSub API
    
    private static var sumsubApiURL: URL? { return URL(string: SumSubAccount.apiUrl) }
    
    static func getBearerToken(onComplete: @escaping (Error?, BearerToken?) -> Void) {
        
        let path = "/resources/auth/login?ttlInSecs=86400"
        
        guard let url = URL(string: path, relativeTo: sumsubApiURL) else {
            onComplete(NSError("Unable to create URLRequest for path: \(path)"), nil)
            return
        }
        
        let basicAuth = Data("\(SumSubAccount.username):\(SumSubAccount.password)".utf8).base64EncodedString()
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Basic \(basicAuth)", forHTTPHeaderField: "Authorization")
        
        send(request) { (error, json, statusCode) in
            
            if statusCode == 401 {
                onComplete(NSError("Wrong credentials"), nil)
            }
            else if let error = error {
                onComplete(error, nil)
            }
            else if let token = json?["payload"] as? String {
                onComplete(nil, token)
            }
            else {
                onComplete(NSError("Unable to get bearer token"), nil)
            }
        }
    }
    
    static func getApplicantFlows(forNewUser: Bool, onComplete: @escaping (Error?, [Flow]?) -> Void) {
        
        get("/resources/sdkIntegrations/flows") { (error, json, statusCode) in
            
            if let error = error {
                onComplete(error, nil)
                return
            }
              
            if
                let list = json?["list"] as? Json,
                let items = list["items"] as? [Json]
            {
                let flows = items.filter { (item) in
                    if let target = item["target"] as? String {
                        let type = item["type"] as? String ?? ""
                        return target == "msdk" && (forNewUser ? type != "actions" : true)
                    } else {
                        return false
                    }
                } .map { (item) -> Flow in
                    return Flow(
                        name: item["name"] as? FlowName ?? "noname",
                        isAction: item["type"] as? String ?? "" == "actions"
                    )
                }
                
                onComplete(nil, flows)
            }
            else {
                onComplete(NSError("Unable to get applicant flows"), nil)
            }
        }
        
    }
    
    // MARK: - Low level

    typealias Json = Dictionary<AnyHashable,Any>
    typealias StatusCode = Int
    typealias ResponseCallback = (Error?, Json?, StatusCode) -> Void
    
    private static var session = URLSession(configuration: URLSessionConfiguration.ephemeral)

    static func get(_ path: String, onComplete: @escaping ResponseCallback) {
        
        request("GET", path, onComplete: onComplete)
    }
    
    static func post(_ path: String, _ json: Json? = nil, onComplete: @escaping ResponseCallback) {
        
        request("POST", path, json, onComplete: onComplete)
    }
    
    static func request(_ method: String, _ path: String, _ json: Json? = nil, isRetring: Bool = false, onComplete: @escaping ResponseCallback) {
        
        guard sumsubApiURL != nil, let url = URL(string: path, relativeTo: sumsubApiURL) else {
            onComplete(NSError("Unable to create URLRequest for path: \(path)"), nil, 0)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        send(request, json) { (error, json, statusCode) in
            
            if statusCode != 401 || isRetring {
                onComplete(error, json, statusCode)
                return
            }
            
            logIntoSumSubAccount { (loginError) in
                if loginError != nil {
                    onComplete(error, json, statusCode)
                } else {
                    self.request(method, path, json, isRetring: true, onComplete: onComplete)
                }
            }
        }
    }
        
    private static func send(_ request: URLRequest, _ json: Json? = nil, onComplete: @escaping ResponseCallback) {
        
        log("%@ %@", request.httpMethod ?? "Send", request.url?.absoluteString ?? "?")
        
        var request = request
        
        if let json = json {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: [])
        }
        
        if request.allHTTPHeaderFields?["Authorization"] == nil, let bearerToken = bearerToken {
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        }
        
        let fail = { (_ error: Any?, _ statusCode: StatusCode) in
            DispatchQueue.main.async {
                if let error = error as? Error {
                    log(error.localizedDescription)
                    onComplete(error, nil, statusCode)
                }
                else if let reason = error as? String {
                    log(reason)
                    onComplete(NSError(reason), nil, statusCode)
                }
                else {
                    onComplete(NSError("Failed for unknown reason"), nil, statusCode)
                }
            }
        }
        
        let success = { (_ json: Json?, _ statusCode: StatusCode) in
            DispatchQueue.main.async {
                onComplete(nil, json, statusCode)
            }
        }
        
        session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                fail(error, 0)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                fail("HTTPURLResponse is expected, but \(type(of: response)) found", 0)
                return
            }
            
            let statusCode = httpResponse.statusCode
            let responseBody = data == nil ? nil : String(data: data!, encoding: .utf8)
            var json: Json?
            
            log("%@ %@ -> %li", request.httpMethod ?? "Got", response?.url?.absoluteString ?? "?", statusCode)
            
            switch statusCode {
            case 200...299:
                
                if let data = data {
                    do {
                        json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Json
                    } catch {
                        fail("JSON is expected but [\(responseBody ?? "")] found", statusCode)
                        return
                    }
                }
                
                success(json, statusCode)
                
            case 401:
                bearerToken = nil
                fallthrough

            default:
                
                fail("Request failed: \(responseBody ?? "")", statusCode)
            }
            
        }.resume()
    }
    
    // MARK: - Logging
    
    private static func log(_ format: String, _ args: CVarArg...) {
        
        print(Date.formatted, "[YourBackend] " + String(format: format, arguments: args))
    }
}
