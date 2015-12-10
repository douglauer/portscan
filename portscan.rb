#!/usr/bin/env ruby

require 'socket'
require 'slop'
require 'ipaddress'
require 'resolv'
require 'thread'
require 'parl'

opts = Slop.parse do |o|
  o.string '-h', '--host', 'hostname or IP address'
  o.integer '-m', '--max', 'maximum port', default:30000
  o.integer '--min', 'minimum port', default:1
  o.bool '--help', 'display usage'
end

if !opts[:host] or opts[:help]
  puts opts
  exit
end

def resolve_host (host)
  if IPAddress.valid? host
    return host
  else
    return Resolv.getaddress host
  end
end

def is_open? (ip,port)
  begin
    Timeout::timeout(0.5) do
      begin
        s = TCPSocket.new ip, port
        s.close
        return true
      end
    end
  rescue
    return false
  end
  return false
end

ip = resolve_host opts[:host]
start = Time.now.to_i

(opts[:min]..opts[:max]).parl(500) do |n|
  if is_open? ip, n
    puts "#{ip}:#{n} is open"
  end
end

puts "Finished (scanned #{opts[:max] - opts[:min]} ports in #{Time.now.to_i - start} seconds)"

