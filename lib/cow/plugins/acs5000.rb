require 'cow/plugins/tmpl'
require 'snmp'

module Cow
  module ACS5000
    OID_DESCRIPTION_LIST = '1.3.6.1.4.1.10418.15.2.2.6.2.1.1.3'.freeze
    OID_TCPPORT_LIST = '1.3.6.1.4.1.10418.15.2.2.6.2.1.1.26'.freeze

    class Port < Cow::Tmpl::Port
    end

    class Server < Cow::Tmpl::Server
      def port(_port)
        return _port if _port.class == Cow::ACS5000::Port
        super
      end

      def connect_command(_port, _user = ENV['USER'])
        "ssh -l #{_user}:#{port(_port).tcp_port} #{@hostname}"
      end

      private

      def get_ports
        ret = []
        snmp do |s|
          s.walk(OID_DESCRIPTION_LIST) do |x|
            next if x.name.last.zero?
            port = x.name.last
            name = x.value.to_s
            tcp_port = snmp { |s| break s.get_value(OID_TCPPORT_LIST + ".#{port}") }

            ret << Cow::ACS5000::Port.new(port, name, tcp_port)
          end
        end

        ret
      end
    end
  end
end
