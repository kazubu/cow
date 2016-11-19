require 'cow/plugins/tmpl'
require 'snmp'

module Cow
  module ACS5000
    OID_DESCRIPTION_LIST = '1.3.6.1.4.1.2925.8.2.6.2.1.1.3'.freeze
    OID_TCPPORT_LIST = '1.3.6.1.4.1.2925.8.2.6.2.1.1.26'.freeze

    class Port < Cow::Tmpl::Port
    end

    module Server
      def port(_port)
        return _port if _port.class == Cow::ACS5000::Port
        super
      end

      def get_ports
        ret = []
        snmp do |s|
          s.walk(OID_DESCRIPTION_LIST) do |x|
            next if x.name.last.zero?
            next unless (/^[0-9a-f]{2}-[0-9a-f]{2}-[0-9a-f]{2}P[0-9]+$/ =~ x.value.to_s).nil?
            port = x.name.last
            name = x.value.to_s
            tcp_port = snmp { |s| break s.get_value(OID_TCPPORT_LIST + ".#{port}") }

            ret << Cow::ACS5000::Port.new(port, name, tcp_port)
          end
        end

        ret
      end
    end

    module Telnet
      class Server < Cow::Tmpl::Server
        include Cow::ACS5000::Server

        def connect_command(_port, _user = ENV['USER'])
          "telnet #{@hostname} #{port(_port).tcp_port}"
        end
      end
    end

    module SSH
      class Server < Cow::Tmpl::Server
        include Cow::ACS5000::Server

        def connect_command(_port, _user = ENV['USER'])
          "ssh -l #{_user}:#{port(_port).tcp_port} #{@hostname}"
        end
      end
    end
  end
end
