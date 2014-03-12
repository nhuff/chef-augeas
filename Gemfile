source 'https://rubygems.org'

gem 'chef','~>11'
group :deploy,:devel do
gem "berkshelf", github: "berkshelf/berkshelf"
end

group :integration,:devel do
gem 'test-kitchen'
gem 'kitchen-vagrant'
gem 'kitchen-docker'
gem 'rake'
end

group :unit,:devel do
gem 'rubocop'
gem 'ruby-augeas'
gem 'minitest'
end

group :devel do
gem 'guard-rubocop'
gem 'guard'
gem 'guard-minitest'
gem 'guard-kitchen'
end
