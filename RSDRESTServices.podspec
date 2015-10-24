#
# Be sure to run `pod lib lint RSDRESTServices.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "RSDRESTServices"
  s.version          = "0.1.0"
  s.summary          = "A short description of RSDRESTServices."

  s.description      = <<-DESC
Simple REST Services client written in Swift for use in iOS 8 or higher
                       DESC

  s.homepage         = "https://github.com/RaviDesai/RSDRESTServices"
  s.license          = 'MIT'
  s.author           = { "RaviDesai" => "ravidesai@me.com" }
  s.source           = { :git => "https://github.com/RaviDesai/RSDRESTServices.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

#  s.resource_bundles = {
#    'RSDRESTServices' => ['Pod/Assets/*.png']
#  }

  s.frameworks = 'Foundation'
  s.dependency 'RSDSerialization', '~> 0.1'
  s.dependency 'OHHTTPStubs', '~> 4.1.0'

end
