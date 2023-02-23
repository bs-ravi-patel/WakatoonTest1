Pod::Spec.new do |spec|
  spec.name                   = 'WakatoonSDK'
  spec.version                = '1.0.0'
  spec.license                = 'MIT'
  spec.homepage               = 'https://github.com/ravipatel-123/WakatoonTest1'
  spec.authors                = { 'Ravi Patel' => 'ravi.patel@bombaysoftwares.com' }
  spec.summary                = 'Wakatoon test pod for develop.'
  spec.swift_version          = '5.0'
  
  spec.ios.deployment_target  = '12.0'
  
  #spec.source                 = { :http => '/Users/bs-mac-4/Documents/Testing 8 Feb/WakatoonTest1/WakatoonSDK.xcframework.zip', :flatten => false}
  spec.source            = { :http => 'https://github.com/ravipatel-123/WakatoonTest1/blob/main/wakatoonSDK.framework.zip' }
  #  spec.source                 = { :git => 'https://github.com/ravipatel-123/WakatoonTest1.git', :tag => spec.version }
  
  #  spec.vendored_framework     = 'WakatoonSDK.xcframework'
  spec.ios.vendored_frameworks = 'wakatoonSDK.xcframework'
  
end
