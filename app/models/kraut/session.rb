module Kraut

  class Session

    include ActiveModel::Validations
    include ActiveModel::Conversion

    attr_accessor :username, :password, :principal
    validates :username, :password, :presence => true

    def initialize(attributes = nil)
      attributes.each {|k,v| send("#{k}=", v) if respond_to?("#{k}=") } if attributes
    end

    def name
      principal.name
    end

    def token
      principal.token
    end

    def allowed_to?(action)
      in_group? Kraut::Rails::Engine.config.authorizations[action]
    end

    def in_group?(groups)
      Array.wrap(groups).any? { |group| principal.member_of? group }
    end

    def valid?
      return unless super
      if self.principal.nil?
        login!
      else
        true
      end
    end

    def self.find_by_token(token)
      self.new(:principal => Kraut::Principal.find_by_token(token))
    end

    def persisted?
      false
    end

  private

    def login!
      self.principal = Kraut::Principal.authenticate(username, password)
      valid_password?
    rescue Kraut::InvalidAuthentication, Kraut::InvalidAuthorization
      errors[:base] << I18n.t("errors.kraut.invalid_credentials")
      false
    rescue Kraut::ApplicationAccessDenied
      errors[:base] << I18n.t("errors.kraut.application_access_denied")
      false
    end

    def valid_password?
      return true unless principal.requires_password_change?

      errors[:base] << I18n.t("errors.kraut.password_expired")
      false
    end

  end

end
