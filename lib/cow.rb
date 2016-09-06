require 'cow/version'
require 'cow/plugins/acs'
require 'cow/plugins/acs5000'
require 'cow/plugins/acs6000'
require 'cow/plugins/digi_ts'
require 'cow/plugins/cisco'

module Cow
  SERVER_TYPES = {
    acs: Cow::ACS::Server,
    acs5000: Cow::ACS5000::Server,
    acs6000: Cow::ACS6000::Server,
    digi_ts_telnet: Cow::DIGI_TS::Telnet::Server,
    cisco_telnet: Cow::Cisco::Telnet::Server,
    cisco_ssh: Cow::Cisco::SSH::Server
  }.freeze
end
