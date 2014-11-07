require 'httpclient'
require 'pp'
require 'json'
require './ce_connection_helper.rb'

require File.dirname(__FILE__) + "/auth_keys.rb"

def create_invoice
   
    # File containing body of JSON to POST
    source_json_file     = "invoice.json"
    
    # Create a request object/hash that we can use to call cloud-elements server
    invoice_request      = @ce_connection_helper.make_req(:post, "finance", "invoices", "v2", source_json_file)
    
    # Make request against cloud-elements server and get response status code
    response             = @ce_http_client.request(invoice_request[:method], invoice_request[:url], invoice_request[:args])
    response_http_status = response.status_code
    
    # Get response body
    response_body = response.body
    response_json = JSON.parse(response_body)
    
    # We'll need the ID of the customer created, for later on
    invoice_id = response_json["id"]
    
    # Output response
    puts "POST /invoices Response:"
    puts JSON.pretty_generate(response_json)

    # Return http status of response
    return response_http_status, invoice_id       
end

def get_invoice(invoice_id)

    # Dummy file name to pass our function prototype for parameter-matching
    # Obviously our GET request doesn't need to pass in json
    source_json_file     = "none"

    # Create a request object/hash that we can use to call cloud-elements server
    invoice_request      = @ce_connection_helper.make_req(:get, "finance", "invoices", "v2", source_json_file, invoice_id)
    
    # Make request against cloud-elements server and get response status code
    response             = @ce_http_client.request(invoice_request[:method], invoice_request[:url], invoice_request[:args])
    response_http_status = response.status_code
    
    # Get response body and JSON-ify it
    response_body = response.body
    response_json = JSON.parse(response_body)
    
    # Output response
    puts "GET /invoices/{id} Response:"
    puts JSON.pretty_generate(response_json)
    
    # Return http status of response
    return response
end

def update_invoice(invoice_id)

    # File containing body of JSON to PATCH
    source_json_file     = "patchinvoice.json"
    
    # Create a request object/hash that we can use to call cloud-elements server
    invoice_request      = @ce_connection_helper.make_req(:patch, "finance", "invoices", "v2", source_json_file, invoice_id)
    
    # Make request against cloud-elements server and get response status code
    response             = @ce_http_client.request(invoice_request[:method], invoice_request[:url], invoice_request[:args])
    response_http_status = response.status_code
            
    # Get response body
    response_body = response.body
    response_json = JSON.parse(response_body)
    
    # Output response
    puts "PATCH /invoices/{id} Response:"
    puts JSON.pretty_generate(response_json)
    
    # Return http status of response
    return response
end

def delete_invoice(invoice_id)

    # Dummy file name to pass our function prototype for parameter-matching
    # Obviously our DELETE request doesn't need to pass in json
    source_json_file     = "none"
    
    # Create a request object/hash that we can use to call cloud-elements server
    invoice_request      = @ce_connection_helper.make_req(:delete, "finance", "invoices", "v2", source_json_file, invoice_id)
    
    # Make request against cloud-elements server and get response status code
    response             = @ce_http_client.request(invoice_request[:method], invoice_request[:url], invoice_request[:args])
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
    response, my_invoice_id = create_invoice()

    # Read customer
    response = get_invoice(my_invoice_id)

    # Update Customer
    response = update_invoice(my_invoice_id)
    if response.status_code == 200 then
        puts "Invoice updated successfully."
    else
        puts "Invoice not updated: #{status}"
        puts response.body
    end    

    # Delete Customer
    response = delete_invoice(my_invoice_id)
    if response.status_code == 200 then
        puts "Invoice deleted successfully."
    else
        puts "Invoice not deleted: #{status}"
        puts response.body
    end

end
