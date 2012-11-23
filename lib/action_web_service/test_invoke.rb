module ActionWebService # :nodoc:
  module TestInvoke # :nodoc:
    module InstanceMethods # :nodoc:
      private
        # invoke the specified API method
        def invoke_direct(method_name, *args)
          invoke_detailed('api', 'api', method_name, *args)
        end

        alias_method :invoke, :invoke_direct

        # invoke the specified API method on the specified service
        def invoke_delegated(service_name, method_name, *args)
          invoke_detailed(service_name.to_s, service_name, method_name, *args)
        end

        # invoke the specified layered API method on the correct service
        def invoke_layered(service_name, method_name, *args)
          invoke_detailed('api', service_name, method_name, *args)
        end

        def invoke_detailed(action, service_name, method_name, *args)
          prepare_request(action, service_name, method_name, *args)
          ActionController::Base.class_eval { include ActionController::Testing }
          @controller.process_with_new_base_test(@request, @response)
          decode_rpc_response
        end

        # ---------------------- internal ---------------------------

        def prepare_request(action, service_name, api_method_name, *args)
          @request.recycle!
          @request.request_parameters['action'] = action
          @request.env['REQUEST_METHOD'] = 'POST'
          @request.env['HTTP_CONTENT_TYPE'] = 'text/xml'
          @request.env['RAW_POST_DATA'] = encode_rpc_call(service_name, api_method_name, *args)
          case protocol
          when ActionWebService::Protocol::XmlRpc::XmlRpcProtocol
            @request.env.delete('HTTP_SOAPACTION')
          end
        end

        def encode_rpc_call(service_name, api_method_name, *args)
          case @controller.web_service_dispatching_mode
          when :direct
            api = @controller.class.web_service_api
          when :delegated, :layered
            api = @controller.web_service_object(service_name.to_sym).class.web_service_api
          end
          protocol.register_api(api)
          method = api.api_methods[api_method_name.to_sym]
          raise ArgumentError, "wrong number of arguments for rpc call (#{args.length} for #{method.expects.length})" if method && method.expects && args.length != method.expects.length
          protocol.encode_request(public_method_name(service_name, api_method_name), args.dup, method.expects)
        end

        def decode_rpc_response
          public_method_name, return_value = protocol.decode_response(@response.body)
          exception = is_exception?(return_value)
          raise exception if exception
          return_value
        end

        def public_method_name(service_name, api_method_name)
          public_name = service_api(service_name).public_api_method_name(api_method_name)
          if @controller.web_service_dispatching_mode == :layered && protocol.is_a?(ActionWebService::Protocol::XmlRpc::XmlRpcProtocol)
            '%s.%s' % [service_name.to_s, public_name]
          else
            public_name
          end
        end

        def service_api(service_name)
          case @controller.web_service_dispatching_mode
          when :direct
            @controller.class.web_service_api
          when :delegated, :layered
            @controller.web_service_object(service_name.to_sym).class.web_service_api
          end
        end

        def protocol
          if @protocol.nil?
            @protocol ||= ActionWebService::Protocol::XmlRpc::XmlRpcProtocol.create(@controller)
          else
            case @protocol
            when :xmlrpc
              @protocol = ActionWebService::Protocol::XmlRpc::XmlRpcProtocol.create(@controller)
            else
              @protocol
            end
          end
        end

        def is_exception?(obj)
          case protocol
          when :xmlrpc, ActionWebService::Protocol::XmlRpc::XmlRpcProtocol
            obj.is_a?(XMLRPC::FaultException) ? obj : nil
          end
        end
    end
  end
end
