Pod::Spec.new do |spec|
  spec.name               = "Qualifio"
  spec.version            = "{{VERSION}}"
  spec.summary            = "Qualifio library for iOS apps"
  spec.description        = <<-DESC
SDK for integrating Qualifio campaigns into mobile apps.

For documentation please refer to: https://developers.qualifio.com
For support please use: mobile@qualifio.com
                            DESC
  spec.homepage           = "https://qualifio.com"
  spec.documentation_url  = "https://developers.qualifio.com"
  spec.license            = { :type => "MIT", :file => 'Qualifio/LICENSE' }
  spec.author             = { "Qualifio" => "mobile@qualifio.com" }
  spec.source             = { :http => "https://cdn-mobile.qualifio.com/libs/ios/#{spec.version}/cocoapods.zip" }
  spec.swift_version      = "6.0"

  # Supported deployment targets
  spec.ios.deployment_target  = "15.0"

  # Subspecs

  spec.subspec 'QualifioKit' do |subspec|
    subspec.vendored_frameworks = "Qualifio/QualifioKit.xcframework"
  end

end
