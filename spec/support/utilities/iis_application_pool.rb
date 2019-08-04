def has_app_pool(_pool_name)
  command = format_powershell_iis_command("Get-WebAppPoolState -Name #{_pool_name}")
  !(on(default, command).stdout =~ %r{Started}i).nil?
end

def create_app_pool(pool_name)
  command = format_powershell_iis_command("New-WebAppPool -Name #{pool_name}")
  on(default, command) unless has_app_pool(pool_name)
end

def remove_app_pool(pool_name)
  command = format_powershell_iis_command("Remove-WebAppPool -Name #{pool_name}")
  on(default, command) if has_app_pool(pool_name)
end

def stop_app_pool(pool_name)
  command = format_powershell_iis_command("Stop-WebAppPool -Name #{pool_name}")
  on(default, command) if has_app_pool(pool_name)
end
