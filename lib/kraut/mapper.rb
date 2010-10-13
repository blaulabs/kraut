module Kraut

  # = Kraut::Mapper
  #
  # Contains methods for mapping attributes.
  module Mapper

    # Accepts a Hash of +attributes+ and assigns them via writer methods.
    # Calls an <tt>after_initialize</tt> method if available.
    def initialize(attributes = {})
      mass_assign! attributes
      after_initialize if respond_to? :after_initialize
    end

    # Expects a Hash of +attributes+ and assigns them via attribute writers.
    def mass_assign!(attributes)
      attributes.each { |key, value| send "#{key}=", value }
    end

  end
end
