require 'rake'

Gem::Specification.new do |s|
  s.name        = 'integrator'
  s.version     = '0.0.1'
  s.date        = '2013-05-15'
  s.summary     = "Simple JSON based integration service"
  s.description = "Simple JSON based integration service for data driven integration between services"
  s.authors     = ["Kimbro Staken"]
  s.email       = 'kstaken@kstaken.com'
  s.files       = FileList["lib/**/*.rb", "test/**/*"].to_a
  s.homepage    =
    'https://github.com/kstaken/Integrator'
end
