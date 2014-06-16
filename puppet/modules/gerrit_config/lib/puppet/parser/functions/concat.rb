# Copyright 2013 OpenStack Foundation.
# Copyright 2013 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# sourced from https://github.com/puppetlabs/puppetlabs-stdlib/blob/master/lib/puppet/parser/functions/concat.rb
# TODO: install_modules.sh in config project should implement stdlib > 4.0
#
# concat.rb
#

module Puppet::Parser::Functions
  newfunction(:concat, :type => :rvalue, :doc => <<-EOS
Appends the contents of array 2 onto array 1.

*Example:*

    concat(['1','2','3'],['4','5','6'])

Would result in:

  ['1','2','3','4','5','6']
    EOS
  ) do |arguments|

    # Check that 2 arguments have been given ...
    raise(Puppet::ParseError, "concat(): Wrong number of arguments " +
      "given (#{arguments.size} for 2)") if arguments.size != 2

    a = arguments[0]
    b = arguments[1]

    # Check that both args are arrays.
    unless a.is_a?(Array) and b.is_a?(Array)
      raise(Puppet::ParseError, 'concat(): Requires array to work with')
    end

    result = a.concat(b)

    return result
  end
end

# vim: set ts=2 sw=2 et :