require 'cow/plugins/tmpl'
require 'snmp'

module Cow
  module DIGI_TS
    OID_DESCRIPTION_LIST = '1.3.6.1.4.1.332.11.5.3.3.25.13.1.29'.freeze
    OID_TCPPORT_BASE = '1.3.6.1.4.1.332.11.5.3.3.20.22.0'.freeze

    class Port < Cow::Tmpl::Port
    end

    module Telnet
      class Server < Cow::Tmpl::Server
        def port(_port)
          return _port if _port.class == Cow::DIGI_TS::Port
          super
        end

        def connect_command(_port, _user = ENV['USER'])
          # "ssh -l #{_user}:#{port(_port).tcp_port+500} #{@hostname}"
          "telnet #{@hostname} #{port(_port).tcp_port}"
        end

        private

        def get_ports
          ret = []

          base_port = snmp{|s| break s.get_value(OID_TCPPORT_BASE) }

          snmp do |s|
            s.walk(OID_DESCRIPTION_LIST) do |x|
              next if x.value.to_s.chomp.empty?
              port = x.name.last
              name = x.value.to_s
              tcp_port = base_port.to_i + port.to_i

              ret << Cow::DIGI_TS::Port.new(port, name, tcp_port)
            end
          end

          ret
        end

        def snmp
          SNMP::Manager.open(host: @hostname, community: @snmp_community, version: :SNMPv1) do|snmp|
            yield(snmp)
          end
        end
      end
    end
  end
end
