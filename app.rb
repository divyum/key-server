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
	'Connected'
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
	key.to_s
end


get '/key/free' do
	#endpoint to get list of free keys
	k = server.free
	res = k.length>0 ? k.to_json + "</br> #{k.length}" : "No key generated"
end


get '/key/blocked' do
	#endpoint to get list of blocked keys
	k = server.blocked
	res = k.length>0 ? k.to_json + "</br> #{k.length}" : "No key generated"
end

get '/key/release/:id' do
	#endpoint to release key
	if server.release params[:id]
		res = "released #{params[:id]}"
	elsif server.free[key]
		res = "Key already free"
	else
		res = "Key not found"
	end
end

get '/key/delete/:id' do
	#endpoint to delete key
	res = server.delete(params[:id])? "Key Deleted" : "Key not found"
end

get '/key/alive/:id' do
	#endpoint to keep the key alive
	res = server.keep_alive(params[:id])? "Updated" : "Key not found"
end

get '/key/info/:id' do
	info = server.key_info params[:id]
	res = info ? info.to_json : "Key not found"
end

