# The Puppet Extensions Module.
#
# This module contains constants that are used when defining extensions.
#
# @api public
#
module PuppetX::PuppetLabs::IIS::Property
  # hash property
  class Hash < Puppet::Property
    validate do |value|
      raise "#{name} should be a Hash" unless value.is_a? ::Hash
    end
  end
end
