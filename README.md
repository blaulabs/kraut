Kraut
=====

Interface for the [Atlassian Crowd](http://www.atlassian.com/software/crowd/) SOAP service.

Installation
------------

    $ gem install kraut (blau.de gemserver)

Crowd endpoint
--------------

Kraut needs to know the SOAP endpoint of your Crowd installation. Set it via:

    Kraut.endpoint = "http://example.com/crowd/services/SecurityServer"

Kraut::Application
------------------

Crowd manages principals and applications. `Kraut::Application` obviously represents the latter.
To authenticate your application with Crowd, you need to provide its name and password:

    Kraut::Application.authenticate "my_app", "secret"

After being authenticated, you can access the following attributes:

    Kraut::Application.name      # => "my_app"
    Kraut::Application.password  # => "secret"
    Kraut::Application.token     # => "Dem7p7Ns97uRV92so4IE1h10"

Kraut stores the time of the latest authentication:

    Kraut::Application.authenticated_at  # => Mon Jan 10 16:35:58 +0100 2011

To check whether the application needs to (re-)authenticate itself, you can use the following method:

    Kraut::Application.authentication_required?(timeout = 10)  # defaults to 10 minutes

Kraut::Principal
----------------

Represents a Crowd principal. To authenticate a principal:

    Kraut::Principal.authenticate "user", "password"

The `.authenticate` method returns a `Kraut::Principal` instance with basic attributes:

    #name      # => "user"
    #password  # => "password"
    #token     # => "3p7Xs3dIuTVb2pO4II1h8A"

It also contains the following attributes:

    #display_name  # => "Chuck Norris"
    #email         # => "chuck.norris@gmail.com"
    #attributes    # => { :display_name => "Chuck Norris", ... }

Make sure to verify whether a principal's password is expired. Principal's with an expired password are
still able to authenticate and access your application.

    Kraut::Principal.requires_password_change?

### Groups

To verify whether a principal belongs to a certain group:

    Kraut::Principal#member_of?(group)

Kraut stores all positive and negative group-requests in a Hash:

    Kraut::Principal#groups  # => { "staff" => true, "supervisor" => false }

Login
-----

In order to provide easy login to your apps, just require 'kraut/rails/engine' instead of just 'kraut'. Then, you'll have a login controller unter '/sessions/new'. To configure it's behaviour, add it in 'config/initializers/kraut.rb':

    Kraut.endpoint = AppConfig.webservices.crowd.baseaddress
    Kraut::Rails::Engine.config.layout = "application"                      # the layout to use for the login page
    Kraut::Rails::Engine.config.webservice = AppConfig.webservices.crowd    # hash containing user and password for authenticatin the crowd app
    Kraut::Rails::Engine.config.authorizations = AppConfig.authorizations   # hash containing :controller_action => [crowd_group1, crowd_group2] pairs
    Kraut::Rails::Engine.config.entry_url = "/"                             # starting url after authentication
