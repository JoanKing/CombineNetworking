//
//  CombineNetworkConfigurable.swift
//  CombineNetworking
//
//  Created by 小冲冲 on 2023/12/31.
//

import SwiftUI
import Foundation

//MARK: - 请求方式
public enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case options = "OPTIONS"
}

//MARK: - URLRequest请求写信的协议配置
public protocol CombineNetworkConfigurable {
    /// scheme
    var scheme: String { get }
    /// host
    var host: String { get }
    /// 路径
    var path: String { get }
    /// headers
    var headers: [String: String]? { get }
    /// 默认的defaultHeaders
    var defaultHeaders: [String: String] { get }
    /// 组合起来的url
    var url: URL? { get }
    /// 接口不同重试的次数
    var retries: Int { get }
    /// 超时的时间
    var timeoutInterval: TimeInterval { get }
}

public extension CombineNetworkConfigurable {
    /// scheme
    var scheme: String {
        return "https"
    }
    /// 默认不设置
    var headers: [String: String]? {
        return nil
    }
    /// 默认的defaultHeaders
    var defaultHeaders: [String: String] {
        return ["Content-Type": "application/json",
                "Accept-Chars": "UTF-8"]
    } 
    /// 请求的URL
    var url: URL? {
        let urlString = "\(scheme)://\(host)\(path)"
        // 使用编码后的 URL 发起请求
        guard let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedString) else { return nil }
        return url
        // return URL(string: urlString)
    }
    /// 重试接口的次数
    var retries: Int {
        return 1
    }
    /// 网络请求超时的时间
    var timeoutInterval: TimeInterval {
        return 15
    }
}

//MARK: - URLRequest一些参数的配置
extension CombineNetworkConfigurable {
    //MARK: 组合请求的 URLRequest
    /// 组合请求的 URLRequest
    /// - Parameters:
    ///   - method: 请求方式
    ///   - parameters: 参数
    ///   - shouldCache: 是否缓存
    /// - Returns: URLRequest
    func getURLRequest(method: HttpMethod, parameters: [String: Any], shouldCache: Bool) -> URLRequest? {
        guard let weakUrl = self.url else {
            return nil
        }
        // 请求的URL
        var encodedUrl = weakUrl
        // Get请求组合参数
        if method == .get, parameters.count > 0 {
            let urlString: String = weakUrl.absoluteString + "?" + parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            guard let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedString) else {
                return nil
            }
            encodedUrl = url
        }
        // URLRequest请求创建
        var urlRequest = URLRequest(url: encodedUrl, cachePolicy: shouldCache ? .useProtocolCachePolicy : .reloadIgnoringLocalCacheData)
        // 请求方式
        urlRequest.httpMethod = method.rawValue
        // 网络请求超时时间
        urlRequest.timeoutInterval = self.timeoutInterval
        
        if method == .post {
            // 设置请求的参数
            urlRequest.httpBody = getHttpBody(body: parameters)
        }
        // 设置allHTTPHeaderFields
        if let weakHeaders = self.headers {
            var defaultHeaders = self.defaultHeaders
            defaultHeaders.merge(weakHeaders) { (_, new) in new }
            urlRequest.allHTTPHeaderFields = defaultHeaders
            debugPrint("测试defaultHeaders：\(defaultHeaders)")
        } else {
            urlRequest.allHTTPHeaderFields = self.defaultHeaders
            debugPrint("测试defaultHeaders：\(self.defaultHeaders)")
        }
        return urlRequest
    }
    
    //MARK: 获取参数Data
    /// 获取参数Data
    /// - Parameter body: 参数
    /// - Returns: Data
    private func getHttpBody(body: [String: Any]?) -> Data? {
        guard let bodyDic = body, let httpBody = try? JSONSerialization.data(withJSONObject: bodyDic, options: []) else {
            return nil
        }
        return httpBody
    }
}

