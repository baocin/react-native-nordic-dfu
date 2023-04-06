require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "react-native-nordic-dfu"
  s.version      = package['version']
  s.summary      = package['description']

  s.authors      = { "Nick Griffith" => "nickolansgriffith@gmail.com" }
  s.homepage     = "https://github.com/Nickolans/react-native-nordic-dfu"
  s.license      = "Apache License 2.0"
  s.platform     = :ios, "12.0"

  s.source       = { :git => "https://github.com/Nickolans/react-native-nordic-dfu.git" }
  s.source_files  = "ios/**/*.{h,m}"

  s.dependency 'React'
  s.dependency 'iOSDFULibrary', '~> 4.12.0'
end
