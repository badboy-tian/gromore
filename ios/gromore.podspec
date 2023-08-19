#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint gromore.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'gromore'
  s.version          = '0.0.4'
  s.summary          = '穿山甲gromore聚合广告插件flutter版'
  s.description      = <<-DESC
穿山甲gromore聚合广告插件flutter版
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.static_framework = true
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  # 穿山甲sdk
  #s.dependency 'Ads-CN','~> 5.4.1.1'
  s.dependency 'MJExtension','~> 3.4.0'
  s.dependency 'CSJMGdtAdapter','~> 4.14.30.0'
  s.dependency 'GDTMobSDK', '~> 4.14.40'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
