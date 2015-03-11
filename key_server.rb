class KeyServer
	attr_reader :free_keys
	attr_reader :blocked_keys

	def initialize
		@free_keys = {}
		@blocked_keys = {}
	end

	def generate length, ttl, timeout
		#generate keys 
		@ttl = ttl
		@timeout = timeout
		@length = length
		while @free_keys.length < @length do
			key = (0...8).map { (65 + rand(26)).chr }.join
			next if @free_keys[key] != nil
			@free_keys[key] = { keep_alive_time: Time.now.to_i, assigned_time: 0}
		end
		return @free_keys
	end

	def get
		#get a key if available
		if @free_keys.length >0
			key, val = @free_keys.shift
			if Time.now.to_i - val[:keep_alive_time] < @ttl
				val[:assigned_time] = Time.now.to_i 
				@blocked_keys[key] = val
			else
				delete key
			end
		end
		return key
	end

	def release key
		#release a key - true if released else false
		if @blocked_keys.has_key?(key)
			@free_keys[key] = @blocked_keys[key]
			@free_keys[key][:assigned_time] = 0
			@blocked_keys.delete key
			return true
		else
			return false
		end
	end

	def delete key
		#delete key - true if deleted else false
		if @free_keys[key] == nil and @blocked_keys[key] == nil
			return false
		end
		@free_keys.delete key
    	@blocked_keys.delete key
    	return true
	end

	def keep_alive key
		#keep the key alive
		if @free_keys[key] == nil and @blocked_keys[key] == nil
			return false

		elsif @free_keys[key] == nil
			if Time.now.to_i - @blocked_keys[key][:keep_alive_time] < @ttl
				@blocked_keys[key][:keep_alive_time] = Time.now.to_i
				return true
			else
				delete key
				return false
			end
		else
			if Time.now.to_i - @free_keys[key][:keep_alive_time] < @ttl
				@free_keys[key][:keep_alive_time] = Time.now.to_i
				return true
			else
				delete key
				return false
			end
		end
	end

	def refresh
		#refresh the keys - i.e. release after 60s and delete if key not hit withing 5 min
		@free_keys.each do |key, val|
			if Time.now.to_i - @free_keys[key][:keep_alive_time] >= @ttl
				delete key
			end
		end

		@blocked_keys.each do |key, val|
			if Time.now.to_i - @blocked_keys[key][:keep_alive_time] >= @ttl
				delete key
			elsif Time.now.to_i - @blocked_keys[key][:assigned_time] >= @timeout
				release key
			end
		end
	end

	def free
		#get free keys
		@free_keys
	end

	def blocked
		#get blocked keys
		return @blocked_keys
	end

	def key_info key
		#print key info
		if @free_keys[key]==nil and @blocked_keys[key]==nil
			return false
		else
			return @free_keys[key]==nil ? @blocked_keys[key] : @free_keys[key]
		end
	end

end


