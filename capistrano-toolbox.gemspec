Gem::Specification.new do |s|
  s.name        = 'capistrano-toolbox'
  s.version     = '0.0.10'
  s.date        = '2013-09-27'
  s.summary     = "Some useful capistrano tools."
  s.description = "Some useful capistrano tools, such as unicorn restart, nginx config etc."
  s.authors     = ["Jean-Louis Giordano", "Magnus Rex", "Petter Remen"]
  s.email       = 'dev@pugglepay.com'
  s.files       = %w[
    lib/capistrano-toolbox.rb
    lib/capistrano-toolbox/check.rb
    lib/capistrano-toolbox/config.rb
    lib/capistrano-toolbox/nginx.rb
    lib/capistrano-toolbox/unicorn.rb
    lib/capistrano-toolbox/helpers.rb
 ]
  s.homepage    = 'http://github.com/spnab/'
  s.add_dependency('capistrano')
end
