require 'snmp'

module Cow
  module Tmpl
    class Port
      attr_accessor :port, :name, :tcp_port

      @port = nil
      @name = nil
      @tcp_port = nil

      def initialize
      end

      def initialize(_port, _name, _tcp_port)
        raise ArgumentError if _port.nil? || _name.nil? || _tcp_port.nil?

        @port = _port.to_s
        @name = _name.to_s
        @tcp_port = _tcp_port.to_s
      end
    end

    class Server
      attr_accessor :hostname

      @hostname = nil
      @snmp_community = nil
      @ports = nil

      def initialize
      end

      def initialize(_hostname, _snmp_community)
        @hostname = _hostname
        @snmp_community = _snmp_community

        @ports = get_ports
      end

      def ports
        update_ports unless @ports

        @ports
      end

      def update_ports
        @ports = get_ports
      end

      def port(_port)
        case _port
        when Fixnum
          ports.each{|p| return p if p.port == _port}
        when String
          ports.each{|p| return p if p.name == _port}
        end

        nil
      end

      def find(_portname)
        _ports = []
        ports.each{|p| _ports << p if p.name.include?(_portname) }
        return _ports
      end

      def connect_command(_port, _user = ENV['USER'])
        raise NotImplementedError
      end

      def connect(_port, _user = nil)
        if _user
          system(connect_command(_port, _user))
        else
          system(connect_command(_port))
        end
      end

      private

      def get_ports
        raise NotImplementedError
      end

      def snmp
        SNMP::Manager.open(host: @hostname, community: @snmp_community) do|snmp|
          yield(snmp)
        end
      end
    end
  end
end
