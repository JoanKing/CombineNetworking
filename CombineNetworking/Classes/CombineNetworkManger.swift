//
//  CombineNetworkManger.swift
//  CombineNetworking
//
//  Created by 小冲冲 on 2023/12/31.
//

import SwiftUI
import Combine

//MARK: - 网络请求类
public class CombineNetworkManger {
    /// 不允许重写
    private init() {}
    /// 单粒
    private static var shared = CombineNetworkManger()
    /// 防止Combine链断掉
    private var subscribtions = Set<AnyCancellable>()
    /// 模型转换
    private lazy var decoder: JSONDecoder = {
        let jsomDecoder = JSONDecoder()
        return jsomDecoder
    }()
    
    /// 网络请求
    /// - Parameters:
    ///   - url: url
    ///   - router: 路由
    ///   - isTransferModel: 是否需要转模型
    ///   - model: 模型
    ///   - shouldCache: 是否缓存
    /// - Returns: 结果
    @discardableResult
    private func performBaseRequest<T: Codable>(parameters: [String: Any] = [:], router: CombineNetworkConfigurable, model: T.Type, isTransferModel: Bool = true, method: HttpMethod = .post, shouldCache: Bool = true) -> AnyPublisher<(entry: T?, dataJson: [String: Any]), CombineNetworkError> {
        // Future 来代替 @escaping
        return Future { [weak self] promise in
            guard let self else {
                return promise(.failure(CombineNetworkError(statusCode: -1005)))
            }
            // 组合请求的URLRequest
            let request = router.getURLRequest(method: method, parameters: parameters, shouldCache: shouldCache)
            guard let weakRequest = request else {
                return promise(.failure(CombineNetworkError(statusCode: -1000)))
            }
            URLSession.shared.dataTaskPublisher(for: weakRequest)
                .retry(router.retries) // 重试的次数
                .tryMap {[weak self] dataElement -> (baseModel: CombineBaseModel<T>?, responeJson: [String: Any]) in
                    guard let weakSelf = self, let httpResponse = dataElement.response as? HTTPURLResponse else {
                        throw CombineNetworkError(statusCode: -3000)
                    }
                    debugPrint("statusCode：\(httpResponse.statusCode)")
                    guard httpResponse.statusCode == 200 else {
                        throw CombineNetworkError(statusCode: httpResponse.statusCode)
                    }
                    guard let serializationJson = try? JSONSerialization.jsonObject(with: dataElement.data) as? [String: Any], let resultJson = serializationJson else {
                        throw CombineNetworkError(statusCode: -1017)
                    }
                    
                    guard let statusCode = resultJson["status"] as? Int else {
                        throw CombineNetworkError(statusCode: -1017)
                    }
                    if statusCode == 1130 || statusCode == 1131 || statusCode == 1132 {
                        throw CombineNetworkError(statusCode: -100, desc: "")
                    }
                    guard let model = try? weakSelf.decoder.decode(CombineBaseModel<T>.self, from: dataElement.data) else {
                        guard let desc = resultJson["desc"] as? String  else {
                            throw CombineNetworkError(statusCode: -1017)
                        }
                        guard statusCode == 0 || statusCode == 200 else {
                            throw CombineNetworkError(statusCode: statusCode, desc: desc)
                        }
                        return (nil, resultJson)
                    }
                    return (model, resultJson)
                }
            // .decode(type: NiuBaseModel<T>.self, decoder: self.decoder)
                .receive(on: RunLoop.main) // 回调回到主线程
                .sink { finished in
                    switch finished {
                    case .failure(let error):
                        if let weakError = error as? CombineNetworkError {
                            debugPrint("报错处理：\(weakError.errorMessage)")
                            promise(.failure(weakError))
                        } else {
                            promise(.failure(CombineNetworkError(statusCode: -1009)))
                        }
                    case .finished:
                        break
                    }
                } receiveValue: { data in
                    if let baseModel = data.baseModel {
                        if baseModel.isOK {
                            if let weakModel = baseModel.data {
                                if let dataDic = data.responeJson["data"] as? [String: Any] {
                                    // 正常数据的解析
                                    promise(.success((weakModel, dataDic)))
                                } else {
                                    // 很多post请求这个是Sting空字符串
                                    promise(.success((weakModel, data.responeJson)))
                                }
                            } else {
                                promise(.failure(CombineNetworkError(statusCode: -1017)))
                            }
                        } else {
                            promise(.failure(CombineNetworkError(statusCode: baseModel.status, desc: baseModel.desc)))
                        }
                    } else {
                        promise(.success((nil, data.1)))
                    }
                }.store(in: &self.subscribtions) // combine 的一个写法，防止combine链断掉
        }.eraseToAnyPublisher() // 擦除其他类型，返回AnyPublisher
    }
}

//MARK: - 测试代码
extension CombineNetworkManger {
    
    /// 网络请求
    /// - Parameters:
    ///   - url: url
    ///   - router: 路由
    ///   - isTransferModel: 是否需要转模型
    ///   - model: 模型
    ///   - shouldCache: 是否缓存
    /// - Returns: 结果
    private func performBaseRequest1<T: Codable>(parameters: [String: Any] = [:], router: CombineNetworkConfigurable, model: T.Type, isTransferModel: Bool = true, method: HttpMethod = .post, shouldCache: Bool = true) -> AnyPublisher<(entry: T?, dataJson: [String: Any]), CombineNetworkError> {
        // Future 来代替 @escaping
        return Future { [weak self] promise in
            guard let self else {
                return promise(.failure(CombineNetworkError(statusCode: -1005)))
            }
            // 组合请求的URLRequest
            let request = router.getURLRequest(method: method, parameters: parameters, shouldCache: shouldCache)
            guard let weakRequest = request else {
                return promise(.failure(CombineNetworkError(statusCode: -1000)))
            }
            URLSession.shared.dataTaskPublisher(for: weakRequest)
                .retry(router.retries) // 重试的次数
                .tryMap {[weak self] dataElement -> (baseModel: CombineBaseModel<T>?, responeJson: [String: Any]) in
                    guard let weakSelf = self, let httpResponse = dataElement.response as? HTTPURLResponse else {
                        throw CombineNetworkError(statusCode: -3000)
                    }
                    debugPrint("statusCode：\(httpResponse.statusCode)")
                    guard httpResponse.statusCode == 200 else {
                        throw CombineNetworkError(statusCode: httpResponse.statusCode)
                    }
                    guard let serializationJson = try? JSONSerialization.jsonObject(with: dataElement.data) as? [String: Any], let resultJson = serializationJson else {
                        throw CombineNetworkError(statusCode: -1017)
                    }
                    
                    guard let statusCode = resultJson["status"] as? Int else {
                        throw CombineNetworkError(statusCode: -1017)
                    }
                    if statusCode == 1130 || statusCode == 1131 || statusCode == 1132 {
                        throw CombineNetworkError(statusCode: -100, desc: "")
                    }
                    guard let model = try? weakSelf.decoder.decode(CombineBaseModel<T>.self, from: dataElement.data) else {
                        guard let desc = resultJson["desc"] as? String  else {
                            throw CombineNetworkError(statusCode: -1017)
                        }
                        guard statusCode == 0 || statusCode == 200 else {
                            throw CombineNetworkError(statusCode: statusCode, desc: desc)
                        }
                        return (nil, resultJson)
                    }
                    return (model, resultJson)
                }
            // .decode(type: NiuBaseModel<T>.self, decoder: self.decoder)
                .receive(on: RunLoop.main) // 回调回到主线程
                .sink { finished in
                    switch finished {
                    case .failure(let error):
                        if let weakError = error as? CombineNetworkError {
                            debugPrint("报错处理：\(weakError.errorMessage)")
                            promise(.failure(weakError))
                        } else {
                            promise(.failure(CombineNetworkError(statusCode: -1009)))
                        }
                    case .finished:
                        break
                    }
                } receiveValue: { data in
                    if let baseModel = data.baseModel {
                        if baseModel.isOK {
                            if let weakModel = baseModel.data {
                                if let dataDic = data.responeJson["data"] as? [String: Any] {
                                    // 正常数据的解析
                                    promise(.success((weakModel, dataDic)))
                                } else {
                                    // 很多post请求这个是Sting空字符串
                                    promise(.success((weakModel, data.responeJson)))
                                }
                            } else {
                                promise(.failure(CombineNetworkError(statusCode: -1017)))
                            }
                        } else {
                            promise(.failure(CombineNetworkError(statusCode: baseModel.status, desc: baseModel.desc)))
                        }
                    } else {
                        promise(.success((nil, data.1)))
                    }
                }.store(in: &self.subscribtions) // combine 的一个写法，防止combine链断掉
        }.eraseToAnyPublisher() // 擦除其他类型，返回AnyPublisher
    }
}

//MARK: - GET、POST扩展方法
extension CombineNetworkManger {
    
    @discardableResult
    public static func getRequest<T: Codable>(router: CombineNetworkConfigurable, parameters: [String: Any] = [:], model: T.Type, shouldCache: Bool = true) -> AnyPublisher<(entry: T?, dataJson: [String: Any]), CombineNetworkError> {
        return CombineNetworkManger.shared.performBaseRequest(parameters: parameters, router: router, model: model, method:.get, shouldCache: shouldCache)
    }
    
    @discardableResult
    public static func postRequest<T: Codable>(router: CombineNetworkConfigurable, parameters: [String: Any] = [:], model: T.Type, shouldCache: Bool = true) -> AnyPublisher<(entry: T?, dataJson: [String: Any]), CombineNetworkError> {
        return CombineNetworkManger.shared.performBaseRequest(parameters:parameters, router: router, model: model, method: .post, shouldCache: shouldCache)
    }
}

//MARK: - 获取Data数据
extension CombineNetworkManger {
    
    //MARK: get网络请求获取返回Data数据
    /// 网络请求获取返回Data数据
    /// - Parameters:
    ///   - parameters: 参数
    ///   - router: 路由
    ///   - method: 请求方式
    ///   - shouldCache: 是否缓存
    /// - Returns: description
    @discardableResult
    public static func performDataRequest(parameters: [String: Any] = [:], router: CombineNetworkConfigurable, method: HttpMethod = .post, shouldCache: Bool = true) -> AnyPublisher<Data, CombineNetworkError> {
        return CombineNetworkManger.shared.performDataRequest(parameters: parameters, router: router, method: method, shouldCache: shouldCache)
    }
    
    //MARK: 网络请求获取返回Data数据
    /// 网络请求获取返回Data数据
    /// - Parameters:
    ///   - parameters: 参数
    ///   - router: 路由
    ///   - method: 请求方式
    ///   - shouldCache: 是否缓存
    /// - Returns: description
    @discardableResult
    private func performDataRequest(parameters: [String: Any] = [:], router: CombineNetworkConfigurable, method: HttpMethod = .post, shouldCache: Bool = true) -> AnyPublisher<Data, CombineNetworkError> {
        // Future 来代替 @escaping
        return Future { [weak self] promise in
            guard let self else {
                return promise(.failure(CombineNetworkError(statusCode: -1005)))
            }
            // 组合请求的URLRequest
            let request = router.getURLRequest(method: method, parameters: parameters, shouldCache: shouldCache)
            guard let weakRequest = request else {
                return promise(.failure(CombineNetworkError(statusCode: -1000)))
            }
            URLSession.shared.dataTaskPublisher(for: weakRequest)
                .retry(router.retries) // 重试的次数
                .tryMap { dataElement -> Data in
                    guard let httpResponse = dataElement.response as? HTTPURLResponse else {
                        throw CombineNetworkError(statusCode: -3000)
                    }
                    debugPrint("statusCode：\(httpResponse.statusCode)")
                    guard httpResponse.statusCode == 200 else {
                        throw CombineNetworkError(statusCode: httpResponse.statusCode)
                    }
                    return dataElement.data
                }
                .receive(on: RunLoop.main) // 回调回到主线程
                .sink { finished in
                    switch finished {
                    case .failure(let error):
                        if let weakError = error as? CombineNetworkError {
                            debugPrint("报错处理：\(weakError.errorMessage)")
                            promise(.failure(weakError))
                        } else {
                            promise(.failure(CombineNetworkError(statusCode: -1009)))
                        }
                    case .finished:
                        break
                    }
                } receiveValue: { data in
                    promise(.success(data))
                }.store(in: &self.subscribtions) // combine 的一个写法，防止combine链断掉
        }.eraseToAnyPublisher() // 擦除其他类型，返回AnyPublisher
    }
}

//MARK: - 不解析网络请求，只看是不是200
/**
 应用场景
 1、埋点：不求结果，上报就行
 2、其他上报的接口，不看返回的结构体
 */
extension CombineNetworkManger {
    //MARK: 不解析网络请求
    /// 不解析网络请求
    /// - Parameters:
    ///   - parameters: 参数
    ///   - router: 路由
    ///   - method: 请求方式
    ///   - shouldCache: 是否缓存
    /// - Returns: description
    @discardableResult
    public static func performNotParsedRequest(parameters: [String: Any] = [:], router: CombineNetworkConfigurable, method: HttpMethod = .post, shouldCache: Bool = true) -> AnyPublisher<Bool, CombineNetworkError> {
        return CombineNetworkManger.shared.performNotParsedRequest(parameters: parameters, router: router, method: method, shouldCache: shouldCache)
    }
    
    //MARK: 不解析网络请求
    /// 不解析网络请求
    /// - Parameters:
    ///   - parameters: 参数
    ///   - router: 路由
    ///   - method: 请求方式
    ///   - shouldCache: 是否缓存
    /// - Returns: description
    @discardableResult
    public func performNotParsedRequest(parameters: [String: Any] = [:], router: CombineNetworkConfigurable, method: HttpMethod = .post, shouldCache: Bool = true) -> AnyPublisher<Bool, CombineNetworkError> {
        // Future 来代替 @escaping
        return Future { [weak self] promise in
            guard let self else {
                return promise(.failure(CombineNetworkError(statusCode: -1005)))
            }
            let request = performDataRequest(router: router)
            request.sink { completion in
                switch completion {
                case .failure(let error):
                    promise(.failure(error))
                case .finished:
                    break
                }
            } receiveValue: { _ in
                promise(.success(true))
            }.store(in: &self.subscribtions)
        }.eraseToAnyPublisher()
    }
}
