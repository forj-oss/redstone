# sub nodetype based on nodetype of original server
# used for mapping generic roles across nodetype's
Facter.add(:subnodetype) do
  setcode do
    nodetype = Facter.value('nodetype')
    subnodetype = ''
    if nodetype == 'maestro' or nodetype == 'vagrant'
      subnodetype = 'puppetmaster'
    end
    subnodetype
  end
end
