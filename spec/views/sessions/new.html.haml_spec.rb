require "spec_helper"

describe "/kraut/sessions/new" do

  before { assign :session, Kraut::Session.new }

  it "should render properly" do
    render
  end

end
