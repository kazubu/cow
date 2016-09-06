require 'cow/plugins/tmpl'
require 'snmp'

module Cow
  module Cisco
    OID_DESCRIPTION_LIST = '1.3.6.1.4.1.9.2.9.2.1.8'.freeze
    TCP_PORT_OFFSET = 2000

    class Port < Cow::Tmpl::Port
    end

    module Server
      def port(_port)
        return _port if _port.class == Cow::Cisco::Port
        super
      end

      def get_ports
        ret = []
        snmp do |s|
          s.walk(OID_DESCRIPTION_LIST) do |x|
            next if x.name.last.zero?
            next if x.value.to_s.empty?
            port = x.name.last
            name = x.value.to_s
            tcp_port = TCP_PORT_OFFSET + port.to_i

            ret << Cow::Cisco::Port.new(port, name, tcp_port)
          end
        end

        ret
      end
    end

    module Telnet
      class Server < Cow::Tmpl::Server
        include Cow::Cisco::Server

        def connect_command(_port, _user = ENV['USER'])
          "telnet #{@hostname} #{port(_port).tcp_port}"
        end
      end
    end

    module SSH
      class Server < Cow::Tmpl::Server
        include Cow::Cisco::Server

        def connect_command(_port, _user = ENV['USER'])
          "ssh -l #{_user}:#{port(_port).port} #{@hostname}"
        end
      end
    end
  end
end
