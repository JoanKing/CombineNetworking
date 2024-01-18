//
//  JKNetworkConfigurable.swift
//  CombineNetworking_Example
//
//  Created by 小冲冲 on 2024/1/2.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import CombineNetworking

enum JKNetworkConfigurable: CombineNetworkConfigurable {
    
    /// 测试链接
    case test
    /// 其他接口
    case other
    
    var host: String {
        switch self {
        case .test:
            return "mock.apifox.com"
        default:
            return ""
        }
    }
    
    var path: String {
        switch self {
        case .test:
            return "/m1/3779443-0-default/homeList"
        case .other:
            return ""
        }
    }
}
