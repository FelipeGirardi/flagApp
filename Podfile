# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'FlagApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for FlagApp
  pod 'SwiftLint'

  # add the Firebase pod for Google Analytics
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/Firestore'
  pod 'FirebaseFirestoreSwift'
  pod 'Firebase/Storage'
  pod 'Firebase'
  pod 'Google-Mobile-Ads-SDK'
  pod 'Introspect'
  pod 'lottie-ios'
    
  # add pods for any other desired Firebase products
  # https://firebase.google.com/docs/ios/setup#available-pods

  # Pods for youtubePlayer
  pod 'youtube-ios-player-helper'

  target 'FlagAppTests' do
      inherit! :search_paths
  end
  
  post_install do |installer|
       installer.pods_project.targets.each do |target|
           target.build_configurations.each do |config|
               config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
           end
       end
    end
end

