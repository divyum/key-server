require 'test/unit'
require_relative 'key_server'

# Test suite for Rover model class.
class TestKeyServer < Test::Unit::TestCase
	def test_to_generate_keys
		#test to check the number of keys generated
		server = KeyServer.new
		keys = server.generate 5, 300, 60
		assert_equal 5, keys.length
	end

	def test_get_key_is_blocked_and_not_free
		server = KeyServer.new
		keys = server.generate 1, 300, 60
		key_obtained = server.get
		blocked = server.blocked
		free = server.free
		assert_equal blocked.keys[0], key_obtained
		assert_equal nil, free.keys[0]
	end

	def test_release_key_is_not_blocked_but_free
		server = KeyServer.new
		keys = server.generate 1, 300, 60
		free = server.free
		key_obtained = server.get
		blocked = server.blocked
		res = server.release key_obtained 
		assert_equal true, res
		assert_equal free.keys[0], key_obtained
		assert_equal blocked.keys[0], nil
	end

	def test_delete_removes_key_permanently
		server = KeyServer.new
		keys = server.generate 3, 300, 60
		free = server.free
		key_obtained = server.get
		blocked = server.blocked
		res = server.delete key_obtained 
		assert_equal true, res
		assert_equal free.keys.include?(key_obtained), false
		assert_equal blocked.keys.include?(key_obtained), false
	end

	def test_keep_alive_updates_keep_alive_time
		server = KeyServer.new
		keys = server.generate 3, 300, 60
		key_obtained = server.get
		blocked = server.blocked
		time_before_keep_alive = blocked[key_obtained][:keep_alive_time]
		sleep 3
		res = server.keep_alive key_obtained
		blocked = server.blocked
		time_after_keep_alive = blocked[key_obtained][:keep_alive_time]
		assert_equal res, true
		assert_not_equal time_before_keep_alive, time_after_keep_alive
	end

	def test_refresh_removes_key_after_ttl_time
		server = KeyServer.new
		keys = server.generate 3, 5, 60
		key_obtained = server.get
		blocked = server.blocked
		assert_equal blocked.include?(key_obtained), true
		sleep 6
		server.refresh
		blocked = server.blocked
		free = server.free
		assert_equal blocked.include?(key_obtained), false
		assert_equal free.include?(key_obtained), false
	end

	def test_refresh_releases_key_after_ttl_time
		server = KeyServer.new
		keys = server.generate 3, 50, 5
		key_obtained = server.get
		blocked = server.blocked
		free = server.free
		assert_equal blocked.include?(key_obtained), true
		assert_equal free.include?(key_obtained), false
		sleep 6
		server.refresh
		blocked = server.blocked
		free = server.free
		assert_equal blocked.include?(key_obtained), false
		assert_equal free.include?(key_obtained), true
	end
end
