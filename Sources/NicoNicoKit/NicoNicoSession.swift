//
//  NicoNicoSession.swift
//  nico
//
//  Created by gibachan on 2017/07/23.
//

import Foundation

public struct NicoNicoSession {
    var session: URLSession!
    var account: NicoNicoAccount
    
    let loginUrl = "https://secure.nicovideo.jp/secure/login"
    
    public init(account: NicoNicoAccount, delegate: URLSessionDelegate) {
        self.session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        self.account = account
    }
    
    public func login(completionHandler: @escaping ((Bool) -> Void)) {
        
        let urlString = "\(loginUrl)?site=niconico"
        let postString = "mail=\(account.email)&password=\(account.password)&as3=1"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        
        let task = session.dataTask(with: request) { _, response, error in
            guard error == nil else {
                completionHandler(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    completionHandler(false)
                    return
            }
            
            // TODO: Check if it is really logged in by checking cookies
            
            completionHandler(true)
        }
        task.resume()
    }
    
    public func logout() {
        guard let storage = session.configuration.httpCookieStorage else {
            return
        }
        
        guard let cookies = storage.cookies else {
            return
        }
        
        for cookie in cookies {
            storage.deleteCookie(cookie)
        }
    }
}
