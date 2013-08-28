Pod::Spec.new do |s|
  s.name         = "BPStatusBar"
  s.version      = "0.9.0"
  s.summary      = "A utility class for displaying status updates in the iOS status bar."
  s.homepage     = "https://github.com/brianpartridge/BPStatusBar"
  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author       = { "Brian Partridge" => "brianpartridge@gmail.com" }
  s.source       = { :path => '~/Projects/*Defaults/Misc/Cocoapods/BPStatusBar' }
  s.platform     = :ios, '5.0'
  s.source_files = 'BPStatusBar', 'BPStatusBar/**/*.{h,m}'
  s.resources 	 = 'BPStatusBar/BPStatusBar.bundle'
  s.requires_arc = true
end
