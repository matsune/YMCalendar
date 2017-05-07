Pod::Spec.new do |s|
  s.name               = "YMCalendar"
  s.version            = "1.0"
  s.summary            = "Monthly event calendar framework in Swift"
  s.homepage           = "https://github.com/matsune/YMCalendar"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  s.license            = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Yuma Matsune" => "yuma.matsune@gmail.com" }
  s.social_media_url   = "https://twitter.com/matsune_ver3"
  s.source             = { :git => "https://github.com/matsune/YMCalendar.git", :tag => s.version.to_s }
  s.platform     = :ios, "8.0"

  s.source_files  = "YMCalendar/**/*.swift"
end
