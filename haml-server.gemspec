# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "haml-server"
  s.version     = "0.2"
  s.platform    = "ruby"
  s.authors     = ["Bernerd Schaefer"]
  s.email       = "bj.schaefer@gmail.com"
  s.homepage    = "http://github.com/bernerdschaefer/haml-server"
  s.summary     = "Server for HAML files"
  s.description = s.summary

  s.add_runtime_dependency "sinatra"
  s.add_runtime_dependency "haml"
  s.add_runtime_dependency "sass"

  s.files         = %w(README bin/haml-server)
  s.executables   = %w(haml-server)
end
