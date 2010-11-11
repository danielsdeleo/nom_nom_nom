# A sample Gemfile
source :gemcutter
#
gem "sinatra"
gem "mustache"
gem "redis"
gem 'yajl-ruby'
gem "rack"
gem "daemons"
gem 'rake'
gem 'chef', "0.9.12"

group(:test) do
  gem 'rspec', '~> 2.1.0'
  gem "thin"
end

group(:deployment) do
  gem "unicorn", "~> 2.0.0"
end