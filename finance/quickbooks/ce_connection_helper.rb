require 'httpclient'
require 'pp'
require 'json'

class CEConnectionHelper
    attr_reader :ce_http_client

    def initialize(config)
            
        @ce_http_client                                = HTTPClient.new
        @ce_http_client.protocol_retry_count           = 2
        @ce_http_client.connect_timeout                = 300
        @ce_http_client.receive_timeout                = 300
        @ce_http_client.send_timeout                   = 300

        # Elements Server
        @base_url                                      = config[:base_url]

        # Authentication information
        @element_token                                 = config[:element_token]
        @user_secret                                   = config[:user_secret]
        @authentication_key                            = "Element #{@element_token}, User #{@user_secret}"

        @req_headers = {}
        @req_headers["Authorization"]                  = @authentication_key
        @req_headers["Content-Type"]                   = "application/json"
    end

    def make_req_url(hub, endpoint, version, id = nil)
        if !id.nil? then
            return "#{@base_url}/elements/api-#{version}/hubs/#{hub}/#{endpoint}/#{id}"
        else
            return "#{@base_url}/elements/api-#{version}/hubs/#{hub}/#{endpoint}"
        end
    end

    def make_req(req_type, hub, endpoint, version, json_file_name, id = nil)

        if req_type == :post || req_type == :patch || req_type == :put then
            json_file                = File.dirname(__FILE__) + "/json/#{json_file_name}"
            json_string              = File.read(json_file)
            args                     = {:header => @req_headers, :body => json_string}
        elsif req_type == :get || :delete then
            args                     = {:header => @req_headers}
        end

        if req_type == :post || req_type == :put then 
            req_url = make_req_url(hub, endpoint, version)
        else
            req_url = make_req_url(hub, endpoint, version, id)
        end

        req = {
            :method => req_type,
            :url => URI.parse(URI.encode(req_url.strip)),
            :args => args
        }

        puts "Testing #{req_type} against #{req_url}..."
        if req_type == :post || req_type == :patch then puts "Body: #{json_string}" end
        return req
    end
    
    def make_inject_req(req_type, hub, endpoint, version, json_file_name, id = nil)
    
        if req_type == :post || req_type == :patch || req_type == :put then
            json_file                = File.dirname(__FILE__) + "/json/#{json_file_name}"
            json_string              = File.read(json_file)
            json_array               = JSON.parse(json_string)            

            # Inject the ID of interest into the JSON we're going to PATCH
            # NOTE: updating a campaign with a contact the expected syntax is
            # to receive an array of JSON objects. The following logic peels
            # out the first element of the array and injects the ID into the json
            # object that it returns            
            json_object = json_array[0]
            json_object["id"] = id
            
            json_array[0] = json_object            
            
            # Inject the ID of interest into the JSON we're going to PATCH            
            # JSON string with id injected
            
            json_string_with_id = json_array.to_json 
            args                     = {:header => @req_headers, :body => json_string}
        elsif req_type == :get || :delete then
            args                     = {:header => @req_headers}
        end

        if req_type == :post || req_type == :put then 
            req_url = make_req_url(hub, endpoint, version)
        else
            req_url = make_req_url(hub, endpoint, version, id)
        end

        req = {
            :method => req_type,
            :url => req_url,
            :args => args
        }

        puts "Testing #{req_type} against #{req_url}..."
        if req_type == :post || req_type == :patch then puts "Body: #{json_string}" end
        return req
    end
    
    def write_json(source_json_filename, json_object)
        target_file_name = source_json_filename.split(".")[0] + "_response.json"
        output_json_file = File.dirname(__FILE__) + "/json/#{target_file_name}"
        pretty_json = JSON.pretty_generate(json_object)
        File.open(output_json_file, 'w') { |file| file.write(pretty_json) }
    end

end