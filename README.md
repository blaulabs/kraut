Kraut
=====

Interface for the [Atlassian Crowd](http://www.atlassian.com/software/crowd/) SOAP service.

Installation
------------

    gem install kraut

Crowd endpoint
--------------

Kraut needs to know the SOAP endpoint of your Crowd installation. Set it via:

```ruby
Kraut.endpoint = "http://example.com/crowd/services/SecurityServer"
```

Kraut::Application
------------------

Crowd manages principals and applications. `Kraut::Application` obviously represents the latter.
To authenticate your application with Crowd, you need to provide its name and password:

```ruby
Kraut::Application.authenticate "my_app", "secret"
```

After being authenticated, you can access the following attributes:

```ruby
Kraut::Application.name     => "my_app"
Kraut::Application.password => "secret"
Kraut::Application.token    => "Dem7p7Ns97uRV92so4IE1h10"
```

Kraut stores the time of the latest authentication:

```ruby
Kraut::Application.authenticated_at  # => Mon Jan 10 16:35:58 +0100 2011
```

To check whether the application needs to (re-)authenticate itself, you can use the following method:

```ruby
Kraut::Application.authentication_required?(timeout = 10)  # defaults to 10 minutes
```

Kraut::Principal
----------------

Represents a Crowd principal. To authenticate a principal:

```ruby
Kraut::Principal.authenticate "user", "password"
```

The `.authenticate` method returns a `Kraut::Principal` instance with basic attributes:

* #name     => "user"
* #password => "password"
* #token    => "3p7Xs3dIuTVb2pO4II1h8A"

It also contains the following attributes:

* #display_name => "Chuck Norris"
* #email        => "chuck.norris@gmail.com"
* #attributes   => { :display_name => "Chuck Norris", ... }

Make sure to verify whether a principal's password is expired. Principal's with an expired password are
still able to authenticate and access your application.

```ruby
Kraut::Principal.requires_password_change?
```

### Groups

To verify whether a principal belongs to a certain group:

```ruby
Kraut::Principal#member_of?(group)
```

Kraut stores all positive and negative group-requests in a Hash:

```ruby
Kraut::Principal#groups => { "staff" => true, "supervisor" => false }
```

Login
-----

In order to provide easy login to your apps, just require 'kraut/rails/engine' instead of just 'kraut':

```ruby
gem "kraut", :require => "kraut/rails/engine"
```

Then, you'll have a login controller unter '/sessions/new'. To configure its behaviour, add it in 'config/initializers/kraut.rb':

```ruby
Kraut.endpoint = AppConfig.webservices.crowd.baseaddress
# the layout to use for the login page
Kraut::Rails::Engine.config.layout = "application"
# hash containing user and password for authenticatin the crowd app
Kraut::Rails::Engine.config.webservice = AppConfig.webservices.crowd
# hash containing :action => [crowd_group1, crowd_group2] pairs
Kraut::Rails::Engine.config.authorizations = AppConfig.authorizations
# starting url after authentication
Kraut::Rails::Engine.config.entry_url = "/"
```

In your controllers, you have three methods to use as before_filter:

* `check_for_crowd_token` => checks for `params[:crowd_token]` and logs in with that token
* `verify_login`          => checks whether a user is logged in and redirects to the login page if necessary
* `verify_access`         => checks whether the logged in user has access to the current action

`verify_access` uses the `Kraut::Rails::Engine.config.authorizations` hash. It checks for controller-action actions (eg :orders_show). If a controller action protected by `verify_access` isn't listed there, no one can access this action!

In your controllers and views, you can access user specific methods:

* `logged_in?`  => checks whether someone is logged in
* `user`        => returns the currently logged in user (or nil)
* `allowed_to?` => checks whether someone is logged in and this user has access to the given action (see `Kraut::Rails::Engine.config.authorizations` above)

Testing authentication/authorization behaviour
----------------------------------------------

In your spec_helper.rb:

```ruby
require "kraut/rails/spec_helper"
```

Then you have in all your specs:

* `create_user` => creates a new user to spec against

And in your controller/view/helper specs:

* `login!`  => log in with a newly created user
* `logout!` => log out again
* `user`    => user you're logged in with

And finally in your controller specs:

* `describe_protected_action` => tests an action protected by `verify_login`/`verify_access`

Example:

```ruby
describe_protected_action "GET :show", :orders_index do
  unauthorized_request { get :show, :id => "5" }
  
  before do
    @order = Order.create
  end
  
  it "should be successful" do
    get :index, :id => @order.id
    response.should be_success
    assigns(:order).should == @order
  end
end
```

This runs three tests:

* the test written in the block above that checks whether the response is a success when logged with a user allowed to do :orders_index
* an automatically generated test that checks that you're redirected to the login page when logged in with a user not allowed to do :orders_index
* an automatically generated test that checks that you're redirected to the login page when not logged in

If you leave out the `action` parameter (:orders_index in the example), the first test only checks with a logged in user and the second test is omitted.

If you leave out the `unauthorized_request`, the second and third test are omitted and only the successful tests are executed.

`unauthorized_request` is run outside the scope of the `describe_protected_action` block, so you can't access stuff initialized within it's before block (eg the @order above).
