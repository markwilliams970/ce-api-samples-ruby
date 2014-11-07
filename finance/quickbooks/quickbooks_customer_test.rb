require 'httpclient'
require 'pp'
require 'json'
require './ce_connection_helper.rb'

require File.dirname(__FILE__) + "/auth_keys.rb"

def create_customer
   
    # File containing body of JSON to POST
    source_json_file     = "customer.json"
    
    # Create a request object/hash that we can use to call cloud-elements server
    customer_request      = @ce_connection_helper.make_req(:post, "finance", "customers", "v2", source_json_file)
    
    # Make request against cloud-elements server and get response status code
    response             = @ce_http_client.request(customer_request[:method], customer_request[:url], customer_request[:args])
    response_http_status = response.status_code
    
    # Get response body
    response_body = response.body
    response_json = JSON.parse(response_body)
    
    # We'll need the ID of the customer created, for later on
    customer_id = response_json["id"]
    
    # Output response
    puts "POST /customers Response:"
    puts JSON.pretty_generate(response_json)

    # Return http status of response
    return response_http_status, customer_id       
end

def get_customer(customer_id)

    # Dummy file name to pass our function prototype for parameter-matching
    # Obviously our GET request doesn't need to pass in json
    source_json_file     = "none"

    # Create a request object/hash that we can use to call cloud-elements server
    customer_request      = @ce_connection_helper.make_req(:get, "finance", "customers", "v2", source_json_file, customer_id)
    
    # Make request against cloud-elements server and get response status code
    response             = @ce_http_client.request(customer_request[:method], customer_request[:url], customer_request[:args])
    response_http_status = response.status_code
    
    # Get response body and JSON-ify it
    response_body = response.body
    response_json = JSON.parse(response_body)
    
    # Output response
    puts "GET /customers/{id} Response:"
    puts JSON.pretty_generate(response_json)
    
    # Return http status of response
    return response
end

def update_customer(customer_id)

    # File containing body of JSON to PATCH
    source_json_file     = "patchcustomer.json"
    
    # Create a request object/hash that we can use to call cloud-elements server
    customer_request      = @ce_connection_helper.make_req(:patch, "finance", "customers", "v2", source_json_file, customer_id)
    
    # Make request against cloud-elements server and get response status code
    response             = @ce_http_client.request(customer_request[:method], customer_request[:url], customer_request[:args])
    response_http_status = response.status_code
            
    # Get response body
    response_body = response.body
    response_json = JSON.parse(response_body)
    
    # Output response
    puts "PATCH /customers/{id} Response:"
    puts JSON.pretty_generate(response_json)
    
    # Return http status of response
    return response
end

def delete_customer(customer_id)

    # Dummy file name to pass our function prototype for parameter-matching
    # Obviously our DELETE request doesn't need to pass in json
    source_json_file     = "none"
    
    # Create a request object/hash that we can use to call cloud-elements server
    customer_request      = @ce_connection_helper.make_req(:delete, "finance", "customers", "v2", source_json_file, customer_id)
    
    # Make request against cloud-elements server and get response status code
    response             = @ce_http_client.request(customer_request[:method], customer_request[:url], customer_request[:args])
    response_http_status = response.status_code
    
    # Return http status of response
    return response
end

# Run CRUD cycle for Quickbooks Customer
begin

    ce_helper_conf = {
        :element_token     => $quickbooks_element_token,
        :user_secret       => $quickbooks_user_secret,
        :base_url          => "https://api.cloud-elements.com"
    }

    @ce_connection_helper  = CEConnectionHelper.new(ce_helper_conf)
    @ce_http_client        = @ce_connection_helper.ce_http_client

    # Create Customer
    response, my_customer_id = create_customer()

    # Read customer
    response = get_customer(my_customer_id)

    # Update Customer
    response = update_customer(my_customer_id)

    # Delete Customer
    response = delete_customer(my_customer_id)
    if response.status_code == 200 then
        puts "Customer deleted successfully."
    else
        puts "Customer not deleted: #{status}"
        puts response.body
    end

end
