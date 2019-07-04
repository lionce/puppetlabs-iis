# The Puppet Extensions Module.
#
# This module contains constants that are used when defining extensions.
#
# @api public
#
module PuppetX::PuppetLabs::IIS::Property
  # PositiveInteger Property
  class PositiveInteger < Puppet::Property
    def insync?(is)
      is.to_i == should.to_i
    end
    validate do |value|
      raise "#{name} should be an Integer" unless value.to_i.to_s == value.to_s
      raise "#{name} should be greater than 0" unless value.to_i > 0
    end
  end
end
