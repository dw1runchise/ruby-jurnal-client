require 'openssl'
require 'base64'

module JurnalApi
  # Defines HTTP request methods
  module Request
    # Perform an HTTP GET request
    def get(path, options={}, raw=false, unformatted=false, no_response_wrapper=no_response_wrapper())
      request(:get, path, options, raw, unformatted, no_response_wrapper)
    end

    # Perform an HTTP POST request
    def post(path, options={}, raw=false, unformatted=false, no_response_wrapper=no_response_wrapper())
      request(:post, path, options, raw, unformatted, no_response_wrapper)
    end

    # Perform an HTTP PUT request
    def put(path, options={},  raw=false, unformatted=false, no_response_wrapper=no_response_wrapper())
      request(:put, path, options, raw, unformatted, no_response_wrapper)
    end

    # Perform an HTTP DELETE request
    def delete(path, options={}, raw=false, unformatted=false, no_response_wrapper=no_response_wrapper())
      request(:delete, path, options, raw, unformatted, no_response_wrapper)
    end

    private

    # Perform an HTTP request
    def request(method, path, options, raw=false, unformatted=false, no_response_wrapper=false)
      response = connection(raw).send(method) do |request|
        path = formatted_path(path) unless unformatted

        case method
        when :get, :delete
          request.url(CGI.escape(path), options)
        when :post, :put
          request.path = CGI.escape(path)
          request.headers['Content-Type'] = 'application/json'
          request.body = options unless options.empty?
        end
      end

      return response if raw
      return response.body if no_response_wrapper
      return Response.create( response.body, {:limit => response.headers['x-ratelimit-limit'].to_i,
                                              :remaining => response.headers['x-ratelimit-remaining'].to_i} )
    end

    def formatted_path(path)
      [path, format].compact.join('.')
    end
  end
end
