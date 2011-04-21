require 'rubygems'
gem 'echoe'
require 'echoe'

Echoe.new("kanned") do |p|
  p.author = "palmade"
  p.project = "palmade"
  p.summary = "Kannel SMS Vas gateway"

  p.dependencies = [ ]

  p.need_tar_gz = false
  p.need_tgz = true

  p.clean_pattern += [ "pkg", "lib/*.bundle", "*.gem", ".config" ]
  p.rdoc_pattern = [ 'README', 'LICENSE', 'COPYING', 'lib/**/*.rb', 'doc/**/*.rdoc' ]
end

gem 'rspec'
