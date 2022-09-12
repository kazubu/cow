require 'cow'
require 'yaml'

module Cow
  class Application
    class Cache
      attr_accessor :servers

      def initialize
        @servers = []
      end

      def add_server(_server)
        @servers.each_with_index do |server, idx|
          if server.hostname == _server.hostname
            @servers[idx] = _server
            return _server
          end
        end

        @servers << _server
      end

      def find_server(_hostname)
        @servers.each do |server|
          return server if server.hostname == _hostname
        end
        nil
      end

      def delete_server(_hostname)
        @servers.each_with_index do |server, idx|
          if server.hostname == _hostname
            @servers.delete_at(idx)
            return true
          end
        end
        false
      end

    end

    CACHE_FILE = '/var/cache/cow/cow.cache'.freeze

    @cache = nil

    def initialize
      @name = 'cow'
    end

    def create_cache(_cache = CACHE_FILE)
      dir_name = File.dirname(_cache)
      if !File.exist?(dir_name)
        puts 'Cache directory is not found. Creating...'
        Dir.mkdir(dir_name)
      else
        if !File.directory?(dir_name)
          raise 'Cache directory path is already found but it is not a directory!!!'
        end
      end

      File.write(_cache, Cow::Application::Cache.new.to_yaml)
    end

    def load_cache(_cache = CACHE_FILE)
      unless File.exist?(_cache)
        puts 'Cache file is not found. Creating...'
        create_cache(_cache)
      end

      if File.size(_cache) < 5
        puts 'Cache file looks empty. Creating...'
        create_cache(_cache)
      end

      cache = YAML.load(File.read(_cache))

      if cache.class == Cow::Application::Cache
        @cache = cache
      else
        raise 'Cache file is corrupt?'
      end
    end

    def edit_cache(_cache = CACHE_FILE)
      unless @cache
        load_cache
      end

      cache = @cache

      File.open(_cache, 'w') do |file|
        puts 'Updating cache file.'
        if file.flock(File::LOCK_EX | File::LOCK_NB)

          begin
            yield cache
          rescue
            cache = @cache
          end

          if cache.class == Cow::Application::Cache
            file.write(cache.to_yaml)
          else
            file.write(@cache.to_yaml)
          end
        else
          raise 'File is already locked.'
        end
      end
      load_cache(_cache)
    end

    def run
      command = ARGV[0]
      option1 = ARGV[1]
      option2 = ARGV[2]
      option3 = ARGV[3]

      case command
      when 'add', 'a'
        cmd_add(option1, option2, option3)
      when 'delete', 'd'
        cmd_delete(option1)
      when 'connect', 'c'
        cmd_connect(option1)
      when 'find', 'f'
        cmd_find(option1)
      when 'list', 'l'
        cmd_list(option1)
      when 'server-list', 's'
        cmd_server_list
      when 'update', 'u'
        cmd_update(option1)
      else
        show_help
      end
    end

    def cmd_add(_hostname, _type, _snmp_community)
      raise ArgumentError unless _hostname.class == String && _type.class == String && _snmp_community.class == String
      raise ArgumentError unless Cow::SERVER_TYPES.keys.include?(_type.to_sym)

      puts "#{_hostname}(#{_type}) will be added"

      server = Cow::SERVER_TYPES[_type.to_sym].new(_hostname, _snmp_community)

      server.ports.each do |port|
        puts '%s %s' % ["#{server.hostname}/#{port.port}".ljust(30), port.name.to_s.ljust(20)]
      end

      load_cache

      edit_cache do |cache|
        cache.add_server server
      end if server
    end

    def cmd_delete(_hostname)
      raise ArgumentError unless _hostname.class == String

      load_cache

      unless @cache.find_server(_hostname)
        puts "#{_hostname} is not found!!"
        return
      end

      puts "#{_hostname} will be deleted"

      edit_cache do |cache|
        cache.delete_server _hostname
      end
    end

    def cmd_connect(_portname)
      raise ArgumentError unless _portname.class == String

      load_cache

      @cache.servers.each do |server|
        server.find(_portname).each do |port|
          if port.name == _portname
            puts "Found on #{server.hostname}/#{port.port}. Connecting..."
            server.connect(port)
            break
          end
        end
      end
    end

    def cmd_find(_keyword)
      raise ArgumentError unless _keyword.class == String

      load_cache
      puts '%s %s %s' % ['SERVER/PORT'.ljust(30), 'PORTNAME'.ljust(20), 'COMMAND']

      @cache.servers.each do |server|
        server.find(_keyword).each do |port|
          puts '%s %s %s' % ["#{server.hostname}/#{port.port}".ljust(30), port.name.to_s.ljust(20), server.connect_command(port)]
        end
      end
    end

    def cmd_list(_hostname)
      load_cache
      puts '%s %s %s' % ['SERVER/PORT'.ljust(30), 'PORTNAME'.ljust(20), 'COMMAND']

      @cache.servers.each do |server|
        if _hostname.nil? || server.hostname == _hostname
          server.ports.each do |port|
            puts '%s %s %s' % ["#{server.hostname}/#{port.port}".ljust(30), port.name.to_s.ljust(20), server.connect_command(port)]
          end
        end
      end
    end

    def cmd_server_list
      load_cache
      puts 'SERVER(TYPE)'

      @cache.servers.each do |server|
        type = nil
        Cow::SERVER_TYPES.each_key{|t| type = t if Cow::SERVER_TYPES[t] == server.class}

        puts "#{server.hostname}(#{type})"
      end
    end

    def cmd_update(_hostname)
      load_cache

      puts 'Updating local cache...'

      edit_cache do |cache|
        cache.servers.each do |server|
          if _hostname.nil? || server.hostname == _hostname
            puts "Updating server #{server.hostname}"
            server.update_ports

            puts '%s %s' % ['SERVER/PORT'.ljust(30), 'PORTNAME'.ljust(20)]
            server.ports.each do |port|
              puts '%s %s' % ["#{server.hostname}/#{port.port}".ljust(30), port.name.to_s.ljust(20)]
            end

            cache.add_server server
          end
        end
      end
    end

    def show_help
      puts <<EOF
cow - Console Server Wrapper

Usage:
  cow [command] [options]

Commands:
  add [hostname] [type] [snmp_community]
    Add new console server.
    available types: #{Cow::SERVER_TYPES.keys.join(' ')}

  delete [hostname]
    Delete existing console server.

  connect [portname]
    Connect to console port.

  find [keyword]
    Find console port which includes given name.

  list [hostname(optional)]
    Show console server port list. If hostname is not specified,
    all console ports will be shown.

  server-list
    Show all console servers.

  update [hostname(optional)]
    Update console server port list. If hostname is not specified,
    all port lists will be updated.
EOF
    end
  end
end
