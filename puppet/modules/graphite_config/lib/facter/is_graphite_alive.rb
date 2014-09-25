# Copyright 2012 Hewlett-Packard Development Company, L.P
#

Facter.add("is_graphite_alive") do
  confine :kernel => "Linux"
  setcode do
    Facter::Util::Resolution.exec(Facter.value('forj_script_path') + 'toolstatus.sh graphite') ? true : false
  end
end