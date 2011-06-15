module Kraut

  module Rails

    module Spec

      module ProtectedAction

        # This shouldn't be called outside of describe_authorized_action,
        # since it'll just be ignored - better situated somewhere else? [thomas, 2011-06-07]
        # used to test unauthenticated/unauthorized access
        # keep in mind that the before/after hooks specified in describe_protected_action
        # don't apply to this request!
        def unauthorized_request(&block)
          @@unauthorized_request = block
        end

        # describes an action protected by kraut:
        # tests if the specs in the block pass when authenticated (and authorized in case +action+ is specified)
        # tests if the action recirects to the login page when not authorized (in case +unauthorized_access+ is called within the block and +action+ is specified)
        # tests if the action recirects to the login page when not authenticated (in case +unauthorized_access+ is called within the block)
        def describe_protected_action(message, action = nil, &block)

          @@unauthorized_request = nil

          describe message do

            describe "authenticated#{" and authorized to do #{action}" if action}" do
              before do
                login! if user.nil?
                user.expects(:allowed_to?).with(action.to_s).at_least_once.returns(true) if action
              end
              module_eval &block
            end

            unauthorized_request = @@unauthorized_request

            describe "authenticated but unauthorized to do #{action}" do
              before do
                login! if user.nil?
                user.expects(:allowed_to?).with(action.to_s).at_least_once.returns(false)
              end
              it "redirects to login page with an alert" do
                instance_eval &unauthorized_request
                response.should redirect_to("/sessions/new")
                flash[:alert].should_not be_nil
              end
            end if action && unauthorized_request

            describe "unauthenticated" do
              before { logout! }
              it "redirects to login page" do
                instance_eval &unauthorized_request
                response.should redirect_to("/sessions/new")
              end
            end if unauthorized_request

          end

        end

      end

    end

  end

end
