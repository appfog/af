module VMC

  # This is the internal VMC version number, and is not necessarily
  # the same as the RubyGem version (VMC::Cli::VERSION).
  VERSION = '0.3.18.1'

  # Targets
  DEFAULT_TARGET = 'https://api.appfog.com'
  DEFAULT_LOCAL_TARGET = 'http://api.vcap.me'

  # General Paths
  INFO_PATH            = 'info'
  GLOBAL_SERVICES_PATH = ['info', 'services']
  GLOBAL_RUNTIMES_PATH = ['info', 'runtimes']
  GLOBAL_INFRAS_PATH   = ['info', 'infras']
  RESOURCES_PATH       = 'resources'

  # User specific paths
  APPS_PATH            = 'apps'
  SERVICES_PATH        = 'services'
  USERS_PATH           = 'users'

end
