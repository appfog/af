# AF

The AppFog CLI. This is the command line interface to AppFog.com

af is based on vmc but will have features specific to the AppFog service as well as having the default target set to AppFog's service

## Installation

There are two ways to install af. Most users should install the RubyGem.

    $ sudo gem install af

You can also check out the source for development. You will need [Bundler](http://gembundler.com/) to build af.

    $ git clone https://github.com/appfog/af.git
    $ cd af
    $ bundle install

## Usage

Showing basic command set. Run with 'help --all' to list all commands.

Getting Started
  info          Display information on the current target, user, etc.
  login [EMAIL] Authenticate with the target
  logout        Log out from the target
  target [URL]  Set or display the target cloud, organization, and space

Applications
  app [APP]             Show app information
  apps                  List your applications
  instances APP [INST]  Update the instances limit for an application
  mem APP [MEM]         Show app memory usage

  Management
    delete APPS...                Delete an application
    push [NAME]                   Push an application, syncing changes if it exists
    rename [APP] [NAME]           Rename an application
    restart APPS...               Stop and start an application
    start APPS...                 Start an application
    stop APPS...                  Stop an application
    clone [SRC_APP] [NAME] [URL]  Clone the application and services

  Information
    env [APP]                 Show all environment variables set for an app
    set-env APP NAME [VALUE]  Set an environment variable
    unset-env APP NAME        Remove an environment variable
    map [APP] [URL]           Add a URL mapping
    unmap [APP] [URL]         Remove a URL mapping

  Download
    download [APP]  Downloads last pushed source to zipfile
    pull [APP]      Downloads last pushed source to app name or path

Services
  service SERVICE Show service information
  services        List your service

  Management
    bind-service [SERVICE] [APP]        Bind a service to an application
    create-service [OFFERING] [NAME]    Create a service
    delete-service [SERVICE]            Delete a service
    unbind-service [SERVICE] [APP]      Unbind a service from an application
    tunnel [INSTANCE] [CLIENT]          Create a local tunnel to a service.
    bind-services [SRC_APP] [DEST_APP]  Bind all services in one app to another.
    export-service [SERVICE]            Export the data from a service
    import-service [SERVICE] [URL]      Import data from url

System
  frameworks  List frameworks
  infras      List infras
  runtimes    List runtimes

Options:
      --[no-]color       Use colorful output
      --[no-]script      Shortcut for --quiet and --force
      --debug            Print full stack trace (instead of crash log)
  -V, --verbose          Print extra information
  -f, --[no-]force       Skip interaction when possible
  -h, --help             Show command usage
  -m, --manifest FILE    Path to manifest file to use
  -q, --[no-]quiet       Simplify output format
  -t, --trace            Show API traffic
  -u, --proxy EMAIL      Act as another user (admin)
  -v, --version          Print version number

## Sample Usage (for PHP apps)

    $ af login developer@example.com
    Attempting login to [https://api.appfog.com]
    Password: *********
    Successfully logged into [https://api.appfog.com]

    $ af update
    Would you like to deploy from the current directory? [Yn]: Y
    Application Name: myapp
    Detected a PHP Application, is this correct? [Yn]:
    1: AWS US East - Virginia
    2: AWS EU West - Ireland
    3: AWS Asia SE - Singapore
    4: Rackspace AZ 1 - Dallas
    5: HP AZ 2 - Las Vegas
    Select Infrastructure: 1
    Application Deployed URL [myapp.aws.af.cm]:
    Memory reservation (128M, 256M, 512M, 1G, 2G) [128M]:
    How many instances? [1]:
    Bind existing services to 'myapp'? [yN]:
    Create services to bind to 'myapp'? [yN]:
    Would you like to save this configuration? [yN]:
    Creating Application: OK
    Uploading Application:
      Checking for available resources: OK
      Processing resources: OK
      Packing application: OK
      Uploading (6K): OK
    Push Status: OK
    Staging Application 'myapp': OK
    Starting Application 'myapp': OK
