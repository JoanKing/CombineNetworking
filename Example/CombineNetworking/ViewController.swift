//
//  ViewController.swift
//  CombineNetworking
//
//  Created by JoanKing on 12/31/2023.
//  Copyright (c) 2023 JoanKing. All rights reserved.
//

import UIKit
import CombineNetworking
import Combine
import SwiftUI

struct YourModel: Codable {
    var dynamicName: String

    private enum CodingKeys: String, CodingKey {
        case dynamicName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        dynamicName = try container.decode(String.self, forKey: DynamicCodingKeys(stringValue: YourModel.getDynamicKeyName())!)
    }

    private static func getDynamicKeyName() -> String {
        // 返回动态的字段名
        return "old_name"
    }
}

struct DynamicCodingKeys: CodingKey {
    var stringValue: String

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    var intValue: Int? { return nil }

    init?(intValue: Int) { return nil }
}


struct CombineBaseModel6: Codable {
    var key1: String
    var key2: String
}

class CombineBaseModel5<T: Codable>: NSObject, Codable {
    /// 自定义状态码
    var status: Int = -1
    /// 自定义状态码
    var age: Int = 9
    
    /// data数据模型
    var data: T?
    
    static var modelKey: String {
         return "status1"
     }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        status = try container.decode(Int.self, forKey: DynamicCodingKeys(stringValue: CombineBaseModel5.modelKey)!)
        debugPrint("打印所有的key：\(container.allKeys)")
    }
}

class ViewController: UIViewController {

    /// 防止combine链断
    private var subscribtions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .brown
        
        let jsonString: String = """
                   {
                     "status1": 30,
                     "age": "10",
                     "data1": {
                       "key1": 123,
                       "key2": "测试"
                     }
                   }
                """
        // 使用示例
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                let model: CombineBaseModel5<CombineBaseModel6> = try JSONDecoder().decode(CombineBaseModel5<CombineBaseModel6>.self, from: jsonData)
                print(model.status) // 输出30，因为height字段被映射到了status属性
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }


    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let vc =  UIHostingController(rootView: HomeView())
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.present(vc, animated: true)
        /*
       let request = CombineNetworkManger.performDataRequest(router: JKNetworkConfigurable.test)
        request.sink { completion in
            switch completion {
            case .failure(let error):
                debugPrint("报错信息：code: \(error.statusCode) msg: \(error.errorMessage)")
            case .finished:
                break
            }
        } receiveValue: { data in
            guard let serializationJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let resultJson = serializationJson else {
                debugPrint("解析data失败")
               return
            }
            debugPrint("打印json数据：\(resultJson)")
        }.store(in: &subscribtions)
         */
    }
}

