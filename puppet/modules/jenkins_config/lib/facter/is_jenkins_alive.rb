# Copyright 2012 Hewlett-Packard Development Company, L.P
#

Facter.add('is_jenkins_alive') do
  confine :kernel => 'Linux'
  setcode do
    ret = Facter::Util::Resolution.exec(Facter.value('forj_script_path') + 'toolstatus.sh  jenkins')
    ret == '0' ? Facter::Util::Resolution.exec('echo true') : Facter::Util::Resolution.exec('echo false')
  end
end