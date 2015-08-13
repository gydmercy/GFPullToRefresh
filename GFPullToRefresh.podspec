Pod::Spec.new do |s|
  s.name         = "GFPullToRefresh"
  s.version      = "1.1.0"
  s.summary      = "a simple and low coupling pull-to-refresh module, very easy to use"
  s.homepage     = "https://github.com/gydmercy/GFPullToRefresh"
  s.license      = "MIT"
  s.author       = { "Mercy" => "bluegyd@vip.qq.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/gydmercy/GFPullToRefresh.git", :tag => s.version }
  s.source_files  = "GFPullToRefresh/*.{h,m}"
  s.resources     = "GFPullToRefresh/*.png"
  s.requires_arc  = true

end
