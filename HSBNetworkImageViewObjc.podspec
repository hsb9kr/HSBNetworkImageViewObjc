#
# Be sure to run `pod lib lint HSBNetworkImageViewObjc.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HSBNetworkImageViewObjc'
  s.version          = '0.0.1'
  s.summary          = 'Network load ImageView.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
HSBNetworkImageViewObjc provides multi thread download image and circle progress.
                       DESC

  s.homepage         = 'https://github.com/hsb9kr/HSBNetworkImageViewObjc'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Hong Sangbo' => 'hsb9kr@gmail.com' }
  s.source           = { :git => 'https://github.com/hsb9kr/HSBNetworkImageViewObjc.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'HSBNetworkImageViewObjc/Classes/*.{h,m}'
end
