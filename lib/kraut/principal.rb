require "kraut/client"
require "kraut/mapper"
require "kraut/application"

module Kraut

  # = Kraut::Principal
  #
  # Represents a principal registered with Crowd.
  class Principal
    include Mapper

    # Expects a +name+ and +password+ and returns a new authenticated <tt>Kraut::Principal</tt>.
    def self.authenticate(name, password)
      response = Client.auth_request :authenticate_principal, :in1 => {
        "aut:application" => Application.name,
        "aut:credential" => { "aut:credential" => password }, "aut:name" => name
      }
      
      new :name => name, :password => password, :token => response[:out]
    end
    
    def self.find_by_token(token)
      response = Client.auth_request :find_principal_by_token, :in1 => token.to_s
      
      # assumption: this works without failure since the auth_request raises an error if the request was not successful!
      new :name => response[:out][:name], :token => token.to_s
    end

    attr_accessor :name, :password, :token

    # Returns the principal name to display.
    def display_name
      attributes[:display_name]
    end

    # Returns the principal's email address.
    def email
      attributes[:mail]
    end

    # Returns whether the principal's password is expired. Principals with an expired password
    # are still able to authenticate and access your application if you do not use this method.
    def requires_password_change?
      attributes[:requires_password_change]
    end

    # Returns a Hash of attributes for the principal.
    def attributes
      @attributes ||= find_attributes
    end

    attr_writer :attributes

    # Returns whether the principal is a member of a given +group+.
    def member_of?(group)
      return groups[group] unless groups[group].nil?
      groups[group] = Client.auth_request(:is_group_member, :in1 => group, :in2 => name)[:out]
    end

    def groups
      @groups ||= {}
    end

    attr_writer :groups

  private

    # Retrieves attributes for the current principal.
    def find_attributes
      response = Client.auth_request(:find_principal_with_attributes_by_name, :in1 => name)[:out]
      
      response[:attributes][:soap_attribute].inject({}) do |memo, entry| 
        memo[entry[:name].snakecase.to_sym] = entry[:values][:string]
        memo
      end
    end

  end
end
