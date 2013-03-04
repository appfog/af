source "http://rubygems.org"

#############
# WARNING: Separate from the Gemspec. Please update both files
#############

gem "json_pure", "~> 1.6"
gem "multi_json", "~> 1.3"
gem "rake"
gem "gem-release"

gem "interact", :git => "git://github.com/vito/interact.git"
gem "cfoundry", :git => "git://github.com/cloudfoundry/vmc-lib.git"
gem "clouseau", :git => "git://github.com/vito/clouseau.git"
gem "mothership", :git => "git://github.com/vito/mothership.git"

git "git://github.com/appfog/af-cli-plugins.git", :branch => "stacked" do # :path =>'../../appfog/af-cli-plugins'
  gem "console-vmc-plugin"
  gem "manifests-vmc-plugin"
  gem "tunnel-vmc-plugin"
  gem "clone-af-cli-plugin", :path =>'../../appfog/af-cli-plugins'
  gem "export-af-cli-plugin", :path =>'../../appfog/af-cli-plugins'
end

group :test do
  gem "rspec", "~> 2.11"
  gem "webmock", "~> 1.9"
  gem "rr", "~> 1.0"
end
