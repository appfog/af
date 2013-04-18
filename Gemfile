source "http://rubygems.org"

#############
# WARNING: Separate from the Gemspec. Please update both files
#############

gem "json_pure", "~> 1.6"
gem "multi_json", "~> 1.3"
gem "rake"
gem "gem-release"

gem "interact"
gem "cfoundry"
gem "clouseau"
gem "mothership"

git "git://github.com/appfog/af-cli-plugins.git", :branch => "stacked" do
  gem "appfog-tunnel-vmc-plugin"
  gem "appfog-vmc-plugin", :path =>'../af-cli-plugins'
end

group :development do
  gem "debugger"
end

group :test do
  gem "rspec", "~> 2.11"
  gem "webmock", "~> 1.9"
  gem "rr", "~> 1.0"
end
