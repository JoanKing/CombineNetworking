//
//  CombineNetworkReachabilityManager.swift
//  CombineNetworking
//
//  Created by 小冲冲 on 2023/12/31.
//

#if os(watchOS)
import WatchConnectivity
#else
import SystemConfiguration
import Foundation
#endif

class CombineNetworkReachabilityManager: NSObject {
    
    static let shared = CombineNetworkReachabilityManager()
    #if os(watchOS)
    var session = WCSession.default
    #else
    private var reachability: SCNetworkReachability?
    #endif
    /// 当前的网络是否可用
    var isEnble: Bool = false
    
    private override init() {
        super.init()
        #if os(watchOS)
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
            isEnble = session.isReachable
            
            debugPrint("网络是否可用：\(session.isReachable)")
            
        }
        #else
        setupReachability()
        #endif
    }
}

#if os(watchOS)
extension CombineNetworkReachabilityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
   
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            isEnble = true
        } else {
            isEnble = false
        }
        
        debugPrint("网络变化：\(session.isReachable)")
    }
}
#else
extension CombineNetworkReachabilityManager {
    
    func setupReachability() {
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)
        
        reachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        if let reachability = reachability {
            var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
            SCNetworkReachabilitySetCallback(reachability, { (target, flags, info) in
                NotificationCenter.default.post(name: Notification.Name("SCNetworkReachabilityChange"), object: nil)
            }, &context)
            
            SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
            networkStatusChanged()
        } else {
            isEnble = false
        }
        
        //  开启网络监听
        NotificationCenter.default.addObserver(self, selector: #selector(networkStatusChanged), name: Notification.Name("SCNetworkReachabilityChange"), object: nil)
    }
    
    //MARK: 网络变化
    /// 网络变化
    @objc func networkStatusChanged() {
        guard let weakReachability = reachability else { return }
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(weakReachability, &flags)
        if flags.contains(.reachable) {
            if flags.contains(.isWWAN) {
                // 使用蜂窝数据网络
                isEnble = true
            } else {
                // 使用Wi-Fi网络
                isEnble = true
            }
        } else {
            // 网络不可用
            isEnble = false
        }
    }
}
#endif
