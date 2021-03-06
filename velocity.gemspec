Gem::Specification.new do |s|
  s.name        = 'velocity'
  s.version     = '0.0.0'
  s.date        = '2015-01-15'
  s.summary     = "veloicty"
  s.description = "Velocity Gem"
  s.authors     = ["Najeer Ahmmad Shaik"]
  s.email       = 'najeers@chetu.com'
  s.files       = ["lib/velocity.rb", "lib/velocity/velocity_processor.rb",
                "lib/velocity/velocity_exception.rb","lib/velocity/velocity_xml_creator.rb","lib/velocity/velocity_connection.rb"]
  s.homepage    = 'http://rubygems.org/gems/velocity'
  s.license     = 'MIT'
  s.add_runtime_dependency 'nokogiri', '~> 1.6', '>= 1.6.5'
  s.add_runtime_dependency 'httparty', '~> 0.13', '>= 0.13.3'
end
