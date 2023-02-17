 //
//  CreateSDKHelper.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 09/12/22.
//


//MARK: - CREATE A SDK -

/*
 
 xcodebuild archive \
 -scheme wakatoonSDK \
 -destination "generic/platform=iOS" \
 -archivePath ../output/wakatoonSDK-iOS \
 SKIP_INSTALL=NO \
 BUILD_LIBRARY_FOR_DISTRIBUTION=YES
 
 
 xcodebuild archive \
 -scheme wakatoonSDK \
 -destination "generic/platform=iOS Simulator" \
 -archivePath ../output/wakatoonSDK-Sim \
 SKIP_INSTALL=NO \
 BUILD_LIBRARY_FOR_DISTRIBUTION=YES
 
 
 cd ..
 
 cd output
 
 xcodebuild -create-xcframework \
 -framework ./wakatoonSDK-iOS.xcarchive/Products/Library/Frameworks/wakatoonSDK.framework \
 -framework ./wakatoonSDK-Sim.xcarchive/Products/Library/Frameworks/wakatoonSDK.framework \
 -output ./WakatoonSDK.xcframework
 
 
 
 
 xcodebuild archive \
 -scheme wakatoonSDK \
 -archivePath "archives/MyFramework-iOS.xcarchive" \
 -destination "generic/platform=iOS" \
 -sdk iphoneos \
 SKIP_INSTALL=NO \
 BUILD_LIBRARY_FOR_DISTRIBUTION=YES
 
 xcodebuild archive \
 -scheme wakatoonSDK \
 -archivePath "archives/MyFramework-iOS-simulator.xcarchive" \
 -destination "generic/platform=iOS Simulator" \
 -sdk iphonesimulator \
 SKIP_INSTALL=NO \
 BUILD_LIBRARY_FOR_DISTRIBUTION=YES
 
 xcodebuild -create-xcframework \
 -framework "archives/MyFramework-iOS.xcarchive/Products/Library/Frameworks/wakatoonSDK.framework" \
 -framework "archives/MyFramework-iOS-simulator.xcarchive/Products/Library/Frameworks/wakatoonSDK.framework" \
 -output "WakatoonSDK.xcframework"
 
 
 
 */
