#
# Be sure to run `pod lib lint FMDB_JING.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FMDB_JING'
  s.version          = '0.1.0'
  s.summary          = 'fmdb的封装，无需写复杂的sql语句'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'fmdb的封装，直接针对于model存取，无需写sql，一句代码搞定增删改查'

  s.homepage         = 'https://github.com/jingchangfa/FMDB_JING'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jing' => '2719519892@qq.com' }
  s.source           = { :git => 'https://github.com/jingchangfa/FMDB_JING.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'FMDB_JING/Classes/*.{h,m}'
  
  # s.resource_bundles = {
  #   'FMDB_JING' => ['FMDB_JING/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
