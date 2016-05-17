source 'http://rubygems.org'

gem 'rails', '3.1.3'
ruby '1.9.3'

group :assets do
  gem 'sass-rails',   '~> 3.1.5'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'therubyracer', platforms: 'ruby'
gem 'thin'
gem 'jquery-rails'
# gem 'parse_resource', :git => 'https://github.com/adelevie/parse_resource.git'
gem 'parse_resource', git: 'https://github.com/mointrantor/parse_resource.git', branch: 'update-parse-header'
gem "parse-ruby-client", '>= 0.3.0'
gem 'jquery-datatables-rails', '1.12.2'
gem "cancan"
gem 'wkhtmltopdf-binary'
gem 'wisepdf'
gem 'roo', '~> 2.3.2'
gem "chartkick"

group :development, :test do
  gem 'debugger'
end

group :test do
  gem 'turn', '0.8.2', :require => false # Pretty printed test output
end