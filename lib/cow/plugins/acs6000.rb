require 'cow/plugins/tmpl'
require 'snmp'

module Cow
  module ACS6000
    OID_DESCRIPTION_LIST = '1.3.6.1.4.1.10418.16.2.3.2.1.4'.freeze
    TCP_PORT_OFFSET = 7000

    class Port < Cow::Tmpl::Port
    end

    module Server
      def port(_port)
        return _port if _port.class == Cow::ACS6000::Port
        super
      end

      def get_ports
        ret = []
        snmp do |s|
          s.walk(OID_DESCRIPTION_LIST) do |x|
            next if x.name.last.zero?
            next unless (/^[0-9a-f]{2}-[0-9a-f]{2}-[0-9a-f]{2}-p-[0-9]+$/ =~ x.value.to_s).nil?
            port = x.name.last
            name = x.value.to_s
            tcp_port = TCP_PORT_OFFSET + port.to_i

            ret << Cow::ACS6000::Port.new(port, name, tcp_port)
          end
        end

        ret
      end
    end

    module Telnet
      class Server < Cow::Tmpl::Server
        include Cow::ACS6000::Server

        def connect_command(_port, _user = ENV['USER'])
          "telnet #{@hostname} #{port(_port).tcp_port}"
        end
      end
    end

    module SSH
      class Server < Cow::Tmpl::Server
        include Cow::ACS6000::Server

        def connect_command(_port, _user = ENV['USER'])
          "ssh -l #{_user}:#{port(_port).tcp_port} #{@hostname}"
        end
      end
    end
  end
end
