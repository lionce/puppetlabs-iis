# The Puppet Extensions Module.
#
# This module contains constants that are used when defining extensions.
#
# @api public
#
module PuppetX::PuppetLabs::IIS::Property
  # name property
  class Name < Puppet::Property
    validate do |value|
      raise("#{value} is not a valid #{name}") unless value =~ %r{^[a-zA-Z0-9\.\-\_\'\s]+$}
    end
  end
end
