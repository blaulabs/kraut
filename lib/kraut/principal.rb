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

    attr_accessor :name, :password, :token

#    def after_initialize
#      mass_assign! find_attributes
#    end

  private

#    # Retrieves attributes for the current principal.
#    def find_attributes
#      response = auth_request :find_principal_with_attributes_by_name, :in1 => name
#      response[:out]
#    end

  end
end
