require 'adeia/controller_resource'
require 'adeia/exceptions'

module Adeia

  module ControllerMethods

    module ClassMethods

      def load_and_authorize(**args)
        ControllerResource.add_before_filter(self, :load_resource_or_records_and_authorize, **args)
      end

      def require_login(**args)
        ControllerResource.add_before_filter(self, :require_login, **args)
      end

    end

    def self.included(base)
      base.extend ClassMethods
      base.helper_method :can?, :rights?
    end

    def load_and_authorize!(**args)
      controller_resource = ControllerResource.new(self, **args)
      resource = controller_resource.load_resource
      controller_resource.authorize!
      return resource
    end

    def authorize_and_load_records!(**args)
      controller_resource = ControllerResource.new(self, **args)
      controller_resource.check_permissions!
      return controller_resource.load_records
    end

    def load_records(**args)
      controller_resource = ControllerResource.new(self, **args)
      return controller_resource.load_records
    end

    def authorize!(**args)
      ControllerResource.new(self, **args).authorize!
    end

    def require_login!
      unless signed_in?
        store_location
        raise LoginRequired
      end
    end

    def can?(action, element, resource=nil)
      controller, resource = ControllerResource.get_controller_and_resource(element, resource)
      ControllerResource.new(self, action: action, controller: controller, resource: resource).authorized?(:can?)
    end

    def rights?(action, element, resource=nil)
      controller, resource = ControllerResource.get_controller_and_resource(element, resource)
      ControllerResource.new(self, action: action, controller: controller, resource: resource).authorized?(:rights?)
    end


    # Redirect the user to the stored url or the default one provided
    #
    # * *Args*    :
    #   - default path to redirect to
    # * *Returns* :
    #
    def redirect_back_or(default, **args)
      redirect_to(cookies[:return_to] || default, **args)
      cookies.delete(:return_to)
    end

    # Store the current url in a cookie
    #
    # * *Args*    :
    #
    # * *Returns* :
    #
    def store_location
      if request.get? && Adeia.api_patterns.all? { |pattern| /^#{pattern}$/.match(request.path).nil? }
        cookies[:return_to] = { value: request.fullpath, expires: 2.minutes.from_now }
      end
    end

  end

end
