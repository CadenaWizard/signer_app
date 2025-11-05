Pod::Spec.new do |s|
  s.name             = 'dlc_wallet'
  s.version          = '0.1.0'
  s.summary          = 'A Flutter plugin for DLC Bitcoin wallet operations using Rust backend'
  s.description      = <<-DESC
A Flutter plugin for DLC Bitcoin wallet operations using Rust backend.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 arm64',
    'OTHER_LDFLAGS' => '-force_load $(PODS_TARGET_SRCROOT)/Classes/libdlcplazacryptlib.a',
    'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64'
  }
  s.swift_version = '5.0'
  
  # Include the Rust native library
  s.vendored_libraries = 'Classes/libdlcplazacryptlib.a'
end
