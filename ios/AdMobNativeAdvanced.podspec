Pod::Spec.new do |spec|
  spec.name = 'AdMobNativeAdvanced'
  spec.version = '1.0.0'
  spec.summary = 'Capacitor plugin for Google AdMob Native Advanced Ads'
  spec.license = 'MIT'
  spec.homepage = 'https://github.com/BrandonKnudsen/admob-native-advanced'
  spec.author = 'Capacitor Community'
  spec.source = { :git => 'https://github.com/BrandonKnudsen/admob-native-advanced.git', :tag => spec.version.to_s }
  spec.source_files = 'ios/Plugin/**/*.{swift,h,m,c,cc,mm,cpp}'
  spec.ios.deployment_target  = '13.0'
  spec.dependency 'Capacitor'
  spec.dependency 'Google-Mobile-Ads-SDK', '~> 10.0'
  spec.swift_version = '5.1'
end 