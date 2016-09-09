require 'cow/version'
require 'cow/plugins/acs'
require 'cow/plugins/acs5000'
require 'cow/plugins/acs6000'
require 'cow/plugins/digi_ts'
require 'cow/plugins/cisco'

module Cow
  SERVER_TYPES = {
    acs_telnet: Cow::ACS::Telnet::Server,
    acs_ssh: Cow::ACS::SSH::Server,
    acs5000_telnet: Cow::ACS5000::Telnet::Server,
    acs5000_ssh: Cow::ACS5000::SSH::Server,
    acs6000_telnet: Cow::ACS6000::Telnet::Server,
    acs6000_ssh: Cow::ACS6000::SSH::Server,
    digi_ts_telnet: Cow::DIGI_TS::Telnet::Server,
    cisco_telnet: Cow::Cisco::Telnet::Server,
    cisco_ssh: Cow::Cisco::SSH::Server
  }.freeze
end
