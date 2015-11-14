#
# Be sure to run `pod lib lint RSDRESTServices.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "RSDRESTServices"
  s.version          = "0.3.4"
  s.summary          = "REST service client written in Swift"

  s.description      = <<-DESC
Simple REST Services client written in Swift for use in iOS 8 or higher
                       DESC

  s.homepage         = "https://github.com/RaviDesai/RSDRESTServices"
  s.license          = 'MIT'
  s.author           = { "RaviDesai" => "ravidesai@me.com" }
  s.source           = { :git => "https://github.com/RaviDesai/RSDRESTServices.git", :tag => s.version.to_s }

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

#  s.resource_bundles = {
#    'RSDRESTServices' => ['Pod/Assets/*.png']
#  }

  s.public_header_files = 'Pod/Classes/**/*.h'

  s.frameworks = 'Foundation'
  s.dependency 'RSDSerialization', '~> 0.3'
  s.dependency 'OHHTTPStubs', '~> 4.1.0'

end
