module FBGraph
  
  class Base
    
    attr_reader :objects , :connection_type
    
    def initialize(client)
      @client = client
    end


    
    def find(objects)
      @objects = objects
      return self
    end
   
  
    def connection(connection_type)
      @connection_type = connection_type
      return self
    end
    
    def params(params)
      @params = params
      return self
    end  
      

    def info(parsed = true)
      if @objects.is_a? Array
        @params.merge!({:ids => ids.join(',')})
        uri = build_open_graph_uri(nil , nil , @params)
      elsif @objects.is_a? String
        uri = build_open_graph_uri(@objects , @connection_type , @params)
      end
      result = @client.consumer.get(uri)
      return parsed  ? JSON.parse(result) : result
    end
  
  
    def publish(parsed = true)
      consume!(:post , parsed)
    end
  
    def delete(parsed = true)
      @params = {:method => 'delete'}
      consume!(:post, parsed)
    end
  
    private
    
    def build_open_graph_uri(id,connection_type = nil, params = {})
      request = "/" + [id , connection_type].compact.join('/')
      request += "?"+params.to_a.map{|p| p.join('=')}.join('&') 
      request
    end
    
    def consume!(verb, parse)
      uri = build_open_graph_uri(@objects , @connection_type , @params)
      result = @client.consumer.send(verb,uri)
      return parsed  ? JSON.parse(result) : result
    end
  end  
end