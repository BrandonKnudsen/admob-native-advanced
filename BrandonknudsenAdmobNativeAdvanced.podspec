Pod::Spec.new do |spec|
  spec.name = 'BrandonknudsenAdmobNativeAdvanced'
  spec.version = '1.0.6'
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
  
  # Use static linking (recommended for Google Mobile Ads SDK v11+)
  spec.static_framework = true
  
  # Configure for static linking compatibility
  spec.pod_target_xcconfig = {
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
    'DEFINES_MODULE' => 'YES',
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES'
  }
  
  # User target configuration for proper linking
  spec.user_target_xcconfig = {
    'OTHER_LDFLAGS' => '$(inherited) -ObjC',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
  }
end 