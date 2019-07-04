# The Puppet Extensions Module.
#
# This module contains constants that are used when defining extensions.
#
# @api public
#
module PuppetX::PuppetLabs::IIS::Property
  # string property
  class String < Puppet::Property
    validate do |value|
      raise "#{name} should be a String" unless value.is_a? ::String
    end
  end
end
