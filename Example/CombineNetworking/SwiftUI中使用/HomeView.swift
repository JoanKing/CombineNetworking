//
//  HomeView.swift
//  CombineNetworking_Example
//
//  Created by 小冲冲 on 2024/1/2.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(content: {
            Button {
                
            } label: {
                Text("测试")
            }
            .frame(width: 300, height: 300)
            .foregroundColor(.red)
            .background(Color.yellow)
            
            Button {
                
            } label: {
                Text("测试")
            }
            .frame(width: 300, height: 300)
            .foregroundColor(.red)
            .background(Color.yellow)
        })
    }
}

#Preview {
    HomeView()
}
