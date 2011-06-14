module Kraut

  # = Kraut::Mapper
  #
  # Contains methods for mapping attributes.
  module Mapper

    # Accepts a Hash of +attributes+ and assigns them via writer methods.
    # Calls an <tt>after_initialize</tt> method if available.
    def initialize(attributes = nil)
      mass_assign! attributes
    end

    # Expects a Hash of +attributes+ and assigns them via attribute writers.
    def mass_assign!(attributes)
      attributes.each { |key, value| send "#{key}=", value } if attributes
    end

  end
end
