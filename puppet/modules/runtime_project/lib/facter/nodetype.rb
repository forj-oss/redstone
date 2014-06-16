# provide default or custom definitions for node type
# nodetype allows us to select what classes/packages to install from hieradata

#TODO: need to find a way to have this in a stdlib
class String
  def to_bool
    return true if self == true || self =~ (/(true|t|yes|y|1)$/i)
    return false if self == false || self.blank? || self =~ (/(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end
end

Facter.add(:nodetype) do
  setcode do
    # match the hostname after we remove number designators
    hostname = Facter.value('hostname')
    nodetype = 'UNDEF'
    # parse for nodetype based on matches for ??-name
    pat = hostname.scan(/(^([a-z0-9]{1,})-(.*))/).flatten.compact
    if pat.length == 3  and pat[1] != '' and pat[1] != nil
      nodetype = pat[2] if pat[2] != '' and pat[2] != nil
    end
    # parse for nodetype based on matches for name##
    pat = hostname.scan(/(^([^0-9\.]+)(.*))/).flatten.compact
    if nodetype == 'UNDEF' and pat.length == 3  and pat[1] != '' and pat[1] != nil
      nodetype = pat[1] if nodetype != '' and nodetype != nil
    end

    # identify if we should use vagrant for the nodetype on testing systems
    vagrant_guest = Facter.value('vagrant_guest')
    nodetype = 'vagrant' if nodetype == 'precise' and vagrant_guest.to_bool
    nodetype
  end
end

