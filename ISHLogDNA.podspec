Pod::Spec.new do |s|
  s.name             = 'ISHLogDNA'
  s.version          = '1.0'
  s.summary          = 'Remote logging for iOS via LogDNA with a simple Objective-C (Swift-compatible) wrapper '
  s.description      = <<-DESC
    This micro-framework supports remote logging via LogDNA on iOS. The framework itself is written in ObjC for easy integration in Swift and ObjC apps.
    DESC
  s.homepage         = 'https://github.com/iosphere/ISHLogDNA'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Felix Lamouroux' => 'felix@iosphere.de' }
  s.source           = { :git => 'https://github.com/iosphere/ISHLogDNA.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/iosphere'

  s.ios.deployment_target = '9.0'

  s.source_files = 'Sources/*.{h,m}'
end
