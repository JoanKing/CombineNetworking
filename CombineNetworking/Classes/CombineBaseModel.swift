//
//  CombineBaseModel.swift
//  CombineNetworking
//
//  Created by 小冲冲 on 2023/12/31.
//
import Foundation

// 定义一个协议
protocol CombineBaseModelProtocol: Codable {
    /// 声明一个类型
    associatedtype T: Codable
    /// 转模型对应的key
    static var modelKey: String { get }
    /// 是否成功，一般来说200是成功，有些服务器返回一个json，可能会有个status，比如：status：200 和 0 都是成功
    var isSuccess: Bool { get }
}

class CombineBaseModel<T: Codable>: NSObject, Codable {
    /// 自定义状态码
    var status: Int = -1
    /// 错误描述信息
    var desc: String = ""
    /// data数据模型
    var data: T?
    /// 是否请求成功
    var isOK: Bool {
        return status == 0 || status == 200
    }
}

