//
//  CombineNetworkError.swift
//  CombineNetworking
//
//  Created by 小冲冲 on 2024/1/1.
//

import UIKit

//MARK: - 错误类型
public struct CombineNetworkError: Error {
    /// 错误码
    public var statusCode: Int
    /// 服务器返回的错误信息
    public var desc: String? = nil
    /// 报错信息解析
    public var errorMessage: String {
        if let weakDesc = desc {
            // 服务器自己的返回的错误
            return weakDesc
        }
        switch statusCode {
        case -999:
            // 请求已取消
            return "请求已取消"
        case -1000:
            // 访问地址异常，请您确认操作是否正确
            return "访问地址异常，请您确认操作是否正确。"
        case -1001, -1004:
            // 网络连接超时
            return "请求超时，请检查您的网络连接并请稍后重试。"
        case -1009:
            // 无法连接至网络
            return "无法连接至网络，请检查您的网络连接并请稍后重试。"
        case -1200:
            // 服务连接失败
            return "无法连接到服务，请检查您的网络连接并请稍后重试。"
        case -3000, -3001, -3002, -3003, -3004, -3005, -3006, -3007:
            // 服务暂时出现问题，请稍后再试
            // return "Text_2884_L".localized()
            return "服务暂时出现问题，请稍后再试。"
        case -1201, -1202, -1203, -1204, -1205, -1206, -2000:
            // 安全验证失败，请稍后再试
            return "安全验证失败，请稍后再试。"
        case -1017, 3840:
            // 无法解析返回数据，请稍后再试
            return "无法解析返回数据，请稍后再试。"
        case -1005:
            // 网络不稳定，请检查您的网络连接并请稍重试
            return "网络不稳定，请检查您的网络连接并请稍后重试。"
        default:
            // 数据请求失败，请稍后再试"
            return "数据请求失败，请稍后再试"
        }
    }
}
