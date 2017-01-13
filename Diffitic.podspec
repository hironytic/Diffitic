Pod::Spec.new do |s|
  s.name         = "Diffitic"
  s.version      = "0.1.0"
  s.summary      = "Detect differences between two sequences"
  s.description  = <<-DESC
    Diffitic is a module for detecting differences between two sequences written in Swift..
  DESC
  s.homepage     = "https://github.com/hironytic/Diffitic"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Hironori Ichimiya" => "hiron@hironytic.com" }
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/hironytic/Diffitic.git", :tag => "v#{s.version}" }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
end
