require_relative 'key_server'
require 'sinatra'
require 'json'

server = KeyServer.new

Thread.new do
	while true do
		sleep 1
		server.refresh
	end
end

get '/' do
	res = {}
	res['status'], res['message'] = 'true', 'Connected'
	content_type :json
	return res.to_json
end

get '/keys' do
	#endpoint to generate keys
	content_type :json
	keys = server.generate 10, 300, 60
	keys.to_json
end

get '/key/get' do
	#endpoint to get key
	key = server.get
	return '404' if key == nil
	content_type :json
	return key
end


get '/key/free' do
	#endpoint to get list of free keys
	k = server.free
 	if k.length>0
 		free={}
 		free['keys'], free['count'] = k, k.length
		res = free.to_json
	else
		 res = "No key generated"
	end
	content_type :json
	return res
end


get '/key/blocked' do
	#endpoint to get list of blocked keys
	k = server.blocked
	if k.length>0
		blocked={}
 		blocked['keys'], blocked['count'] = k, k.length
		res = blocked.to_json
	else
		 res = "No key generated"
	end
	content_type :json
	return res
end

get '/key/release/:id' do
	#endpoint to release key
	res = {}
	if server.release params[:id]
		res['status'] = true
		res['message'] = "Released"
	elsif server.free[params[:id]]
		res['status'] = false
		res['message'] = "Key already free"
	else
		res['status'] = false
		res['message'] = "Key not found"
	end
	content_type :json
	return res.to_json
end

get '/key/delete/:id' do
	#endpoint to delete key
	res = {}
	res['status'] = server.delete(params[:id])
	res['message'] = res['status'] ? "Key Deleted" : "Key not found"
	content_type :json
	return res.to_json
end

get '/key/alive/:id' do
	#endpoint to keep the key alive
	res = {}
	res['status'] = server.keep_alive(params[:id])
	res['message'] = res['status'] ? "Updated" : "Key not found"
	content_type :json
	return res.to_json
end

get '/key/info/:id' do
	#display key information
	content_type :json
	info = server.key_info params[:id]
	res = info ? info.to_json : "Key not found"
end

error Sinatra::NotFound do
	res = {}
	res['status'] = false
	res['message'] = "Invalid URL"
	content_type :json
	return res.to_json
end
