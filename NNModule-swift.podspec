#
# Be sure to run `pod lib lint NNModule.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NNModule-swift'
  s.version          = '1.0.6'
  s.summary          = 'a module decoupling tool under Swift project'
  s.homepage         = 'https://github.com/YiHuaXie/NNModule'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'YiHuaXie' => 'xyh30902@163.com' }
  s.source           = { :git => 'https://github.com/YiHuaXie/NNModule.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'

  # ModuleManager
  s.subspec 'ModuleManager' do |ss|
    ss.source_files = 'NNModule/ModuleManager/**/*'
    ss.dependency 'NNModule-swift/URLRouter'
    ss.dependency 'NNModule-swift/StickyNotification'
    ss.dependency 'CocoaLumberjack'
  end
  
  # URLRouter
  s.subspec 'URLRouter' do |ss|
    ss.source_files = 'NNModule/URLRouter/*'
    ss.subspec 'Navigator' do |sss|
      sss.source_files = 'NNModule/URLRouter/Navigator.swift'
      sss.dependency 'YYModel'
      sss.dependency 'CocoaLumberjack/Core'
    end
  end

  # EventTransfer
  s.subspec 'EventTransfer' do |ss|
    ss.source_files = 'NNModule/EventTransfer/*'
    ss.dependency 'SnapKit'
  end

  # StickyNotification
  s.subspec 'StickyNotification' do |ss|
    ss.source_files = 'NNModule/StickyNotification/*'
  end
  # s.resource_bundles = {
  #   'NNModule' => ['NNModule/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
