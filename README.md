Kraut
=====

Interface for the [Atlassian Crowd](http://www.atlassian.com/software/crowd/) SOAP service.

Installation
------------

Kraut is available through [Rubygems](http://rubygems.org/gems/kraut) and can be installed via:

    $ gem install kraut

Crowd endpoint
--------------

Kraut needs to know the SOAP endpoint of your Crowd installation. Set it via:

    Kraut.endpoint = "http://example.com/crowd/services/SecurityServer"

Kraut::Application
------------------

Crowd manages principals and applications. `Kraut::Application` obviously represents the latter.
To authenticate your application with Crowd, you need its name and password:

    Kraut::Application.authenticate "my_app", "secret"

After being authenticated, you can access the following attributes:

    .name      # => "appname"
    .password  # => "password"
    .token     # => "Dem7p7Ns97uRV92so4IE1h10"

Kraut::Principal
----------------

Represents a registered Crowd principal. To authenticate a principal:

    Kraut::Principal.authenticate "user", "password"

This returns a `Kraut::Principal` instance with various attributes:

    #name      # => "user"
    #password  # => "password"
    #token     # => "3p7Xs3dIuTVb2pO4II1h8A"

Kraut::Role
-----------

Roles can be assigned to principals in order for them to have a specific position inside an application.
`Kraut::Role` contains methods for working with roles.

    .all_names            # Returns an Array containing all role names
    .member?(name, role)  # Returns whether a principal with a given name belongs to a group

Work in progress
----------------

This library is far from complete. Please just let us know if you need a specific feature.
