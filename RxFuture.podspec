Pod::Spec.new do |s|
  s.name = "RxFuture"
  s.version = "5.1.0"
  :xa
  s.summary = "A library to provide Future/Promise pattern API that is backed by RxSwift."

  s.description = <<-DESC
    This is a library to provide Future/Promise pattern API that is backed by RxSwift.
                         DESC

  s.homepage = "https://github.com/muukii/RxFuture"
  s.license = "MIT"
  s.author = { "Muukii" => "muukii.app@gmail.com" }
  s.source = { :git => "https://github.com/muukii/RxFuture.git", :tag => s.version.to_s }

  s.requires_arc = true
  s.swift_version = "5.3"

  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "3.0"
  s.tvos.deployment_target = "9.0"

  s.source_files = "RxFuture/*.swift"

  s.frameworks = "Foundation"
  s.dependency "RxSwift", "~> 6"
end
