# The Puppet Extensions Module.
#
# This module contains constants that are used when defining extensions.
#
# @api public
#
module PuppetX::PuppetLabs::IIS::Property
  # path property
  class Path < Puppet::Property
    validate do |value|
      unless value =~ %r{/^.:(\/|\\)/} || value =~ %r{^\\\\[^\\]+\\[^\\]+}
        raise("#{name} should be a path (local or UNC) not '#{value}'")
      end
    end

    def property_matches?(current, desired)
      current.casecmp(desired.downcase).zero?
    end
  end
end
