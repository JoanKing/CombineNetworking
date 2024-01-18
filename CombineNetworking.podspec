#
# Be sure to run `pod lib lint CombineNetworking.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CombineNetworking'
  s.version          = '0.1.0'
  s.summary          = 'Combine封装的一个简洁的网络请求'
  s.description      = 'Combine封装的一个简洁的网络请求，不断的完善中......'

  s.homepage         = 'https://github.com/JoanKing/CombineNetworking'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'JoanKing' => 'jkironman@163.com' }
  s.source           = { :git => 'https://github.com/JoanKing/CombineNetworking.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://github.com/JoanKing'

  s.ios.deployment_target = '13.0'
  s.tvos.deployment_target = "12.0"
  s.osx.deployment_target = "10.14"
  s.watchos.deployment_target = "2.0"
  # swift 支持的版本
  s.swift_version = '5.0'
  # 要求是ARC
  s.requires_arc = true
  # 表示源文件的路径，这个路径是相对podspec文件而言的。（这属性下面单独讨论）
  s.source_files = 'CombineNetworking/Classes/**/*'
  
  # s.resource_bundles = {
  #   'CombineNetworking' => ['CombineNetworking/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
end
