#
#  Be sure to run `pod spec lint ISHLogDNA.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "ISHLogDNA"
  s.version      = "0.0.2"
  s.summary      = "This micro-framework supports remote logging via LogDNA on iOS."
  s.description  = <<-DESC
  This micro-framework supports remote logging via LogDNA on iOS. The framework itself is written in ObjC for easy integration in Swift and ObjC apps.
  Requires a deployment target of iOS 9 and above. 
                   DESC

  s.homepage     = "https://github.com/iosphere/ISHLogDNA"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license      = { :type => "MIT", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = { "Preston Farr" => "xavierproductions05@gmail.com" }
  s.authors            = { "Preston Farr" => "xavierproductions05@gmail.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.platform     = :ios, "9.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/iosphere/ISHLogDNA.git", :tag => "#{s.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "ISHLogDNAService", "Classes/**/*.{h,m}"

end
