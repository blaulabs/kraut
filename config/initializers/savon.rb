# TODO should be testet (with savon_model in deps) [thomas, 2011-06-10]
Savon::Model.handle_response = Proc.new do |response|
  if response.soap_fault?
    begin
     if response.to_hash[:fault][:detail][:voucher_exception][:error_code] == "NOT_AUTHORIZED"
       raise SecurityError
     end
    rescue NoMethodError
    end
  end
  response
end if defined?(Savon::Model)
