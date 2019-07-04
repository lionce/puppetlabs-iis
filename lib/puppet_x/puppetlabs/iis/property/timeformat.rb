# The Puppet Extensions Module.
#
# This module contains constants that are used when defining extensions.
#
# @api public
#
module PuppetX::PuppetLabs::IIS::Property
  # TimeFormat property
  class TimeFormat < Puppet::Property
    validate do |value|
      raise "#{name} should match datetime format 00:00:00 or 0.00:00:00" unless value =~ %r{^(\d+\.)?\d\d:\d\d:\d\d$}
    end
  end
end
