# The Puppet Extensions Module.
#
# This module contains constants that are used when defining extensions.
#
# @api public
#
module PuppetX::PuppetLabs::IIS::Property
  # readOnly Property
  class ReadOnly < Puppet::Property
    validate do |_value|
      raise "#{name} is read-only and is only available via puppet resource."
    end
  end
end
