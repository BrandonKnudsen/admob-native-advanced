Pod::Spec.new do |spec|
  spec.name = 'BrandonknudsenAdmobNativeAdvanced'
  spec.version = '1.0.1'
  spec.summary = 'Capacitor plugin for Google AdMob Native Advanced Ads'
  spec.license = 'MIT'
  spec.homepage = 'https://github.com/BrandonKnudsen/admob-native-advanced'
  spec.author = 'Capacitor Community'
  spec.source = { :git => 'https://github.com/BrandonKnudsen/admob-native-advanced.git', :tag => spec.version.to_s }
  spec.source_files = 'ios/Plugin/**/*.{swift,h,m,c,cc,mm,cpp}'
  spec.ios.deployment_target  = '13.0'
  spec.dependency 'Capacitor'
  spec.dependency 'Google-Mobile-Ads-SDK', '~> 11.13.0'
  spec.swift_version = '5.1'
  
  # Use dynamic linking to avoid static linking conflicts
  spec.static_framework = false
  spec.pod_target_xcconfig = {
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
    'DEFINES_MODULE' => 'YES',
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES',
    'MACH_O_TYPE' => 'mh_dylib'
  }
  
  # Force dynamic linking for all dependencies
  spec.user_target_xcconfig = {
    'OTHER_LDFLAGS' => '$(inherited) -ObjC',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
    'MACH_O_TYPE' => 'mh_dylib'
  }
end 