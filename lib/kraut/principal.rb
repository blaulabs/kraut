require "kraut/client"
require "kraut/mapper"
require "kraut/application"

module Kraut

  # = Kraut::Principal
  #
  # Represents a principal registered with Crowd. Principals can have roles and belong to groups.
  class Principal
    include Client
    include Mapper

    # Expects a +name+ and +password+ and returns a new authenticated <tt>Kraut::Principal</tt>.
    def self.authenticate(name, password)
      response = auth_request :authenticate_principal, :in1 => {
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
      @groups ||= []
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
      return true if groups.include? group_name

      member_of = auth_request(:is_group_member, member_of_request_hash(group_name))[:out]
      groups << group_name if member_of
      member_of
    end

  private
    
    def member_of_request_hash(group_name)
      { :in1 => group_name, :in2 => name }
    end

    # Retrieves attributes for the current principal.
    def find_attributes
      response = auth_request(:find_principal_with_attributes_by_name, :in1 => name)[:out]
      base_attributes = response.delete :attributes
      
      response[:params] = base_attributes[:soap_attribute].inject({}) do |memo, entry| 
        memo[entry[:name].snakecase.to_sym] = entry[:values][:string]
        memo
      end
      
      response
    end

  end
end
