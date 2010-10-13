class Fixture

  class << self
    def [](*args)
      new(*args).to_s
    end

    def fixtures
      @fixtures ||= {}
    end
  end

  def initialize(*args)
    self.fixture = args.join("/")
  end

  attr_accessor :fixture

  def to_s
    self.class.fixtures[fixture] ||= read_file
  end

private

  def read_file
    file_path = File.expand_path("../../fixtures/#{fixture}.xml", __FILE__)
    raise ArgumentError, "Unable to load: #{file_path}" unless File.exist? file_path
    
    File.read file_path
  end

end
