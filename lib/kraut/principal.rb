require "kraut/client"
require "kraut/mapper"
require "kraut/application"

module Kraut

  # = Kraut::Principal
  #
  # Represents a principal registered with Crowd. Principals can have roles and belong to groups.
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

    attr_accessor :name, :password, :token, :attributes, :groups

    def attributes
      @attributes ||= find_attributes
    end

    def groups
      @groups ||= {}
    end

    def display_name
      attributes[:params][:display_name]
    end

    def requires_password_change?
      attributes[:params][:requires_password_change]
    end

    def email
      attributes[:params][:mail]
    end

    def member_of?(group_name)
      return groups[group_name] unless groups[group_name].nil?
      groups[group_name] = Client.auth_request(:is_group_member, :in1 => group_name, :in2 => name)[:out]
    end

  private

    # Retrieves attributes for the current principal.
    def find_attributes
      response = Client.auth_request(:find_principal_with_attributes_by_name, :in1 => name)[:out]
      base_attributes = response.delete :attributes
      
      response[:params] = base_attributes[:soap_attribute].inject({}) do |memo, entry| 
        memo[entry[:name].snakecase.to_sym] = entry[:values][:string]
        memo
      end
      
      response
    end

  end
end
