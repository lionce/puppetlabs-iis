require 'spec_helper_acceptance'

describe 'iis_application_pool' do
  context 'with default parameters' do
    pool_name = define_pool_name

    describe 'applies the manifest twice' do
      manifest = <<-HERE
          iis_application_pool { '#{pool_name}':
            ensure => 'present'
          }
        HERE
      it_behaves_like 'an idempotent resource', manifest
    end

    context 'when puppet resource is run' do
      describe 'iis_appplication_pool is present' do
        puppet_resource_should_show('ensure', 'present', resource('iis_application_pool', pool_name))
      end

      it 'removes app poll' do
        remove_app_pool(pool_name)
      end
    end
  end

  context 'with valid parameters defined' do
    pool_name = define_pool_name

    describe 'applies the manifest twice' do
      manifest = <<-HERE
          iis_application_pool { '#{pool_name}':
            ensure                  => 'present',
            managed_pipeline_mode   => 'Integrated',
            managed_runtime_version => '',
            state                   => 'Stopped'
          }
        HERE

      it_behaves_like 'an idempotent resource', manifest
    end

    context 'when puppet resource is run' do
      # result = resource('iis_application_pool', pool_name)
      describe 'property has the correct value' do
        puppet_resource_should_show('ensure', 'present', resource('iis_application_pool', pool_name))

        # Properties introduced in IIS 7.0 (Server 2008 - Kernel 6.1)
        puppet_resource_should_show('managed_pipeline_mode', 'Integrated', resource('iis_application_pool', pool_name))
        puppet_resource_should_show('state', 'Stopped', resource('iis_application_pool', pool_name))
        puppet_resource_should_show('auto_start', :true, resource('iis_application_pool', pool_name))
        puppet_resource_should_show('enable32_bit_app_on_win64', :false, resource('iis_application_pool', pool_name))
        puppet_resource_should_show('enable_configuration_override', :true, resource('iis_application_pool', pool_name))
        puppet_resource_should_show('pass_anonymous_token', :true, resource('iis_application_pool', pool_name))
        puppet_resource_should_show('start_mode', 'OnDemand', resource('iis_application_pool', pool_name))
        puppet_resource_should_show('queue_length', '1000', resource('iis_application_pool', pool_name))
        puppet_resource_should_show('cpu_action', 'NoAction', resource('iis_application_pool', pool_name))
        puppet_resource_should_show('cpu_limit', '0', resource('iis_application_pool', pool_name))
        puppet_resource_should_show('cpu_reset_interval', '00:05:00', resource('iis_application_pool', pool_name))
        puppet_resource_should_show('cpu_smp_affinitized', :false, resource('iis_application_pool', pool_name))
        puppet_resource_should_show('cpu_smp_processor_affinity_mask', '4294967295', resource('iis_application_pool', pool_name))
        puppet_resource_should_show('cpu_smp_processor_affinity_mask2', '4294967295', resource('iis_application_pool', pool_name))
        puppet_resource_should_show('identity_type', 'ApplicationPoolIdentity', resource('iis_application_pool', pool_name))
        puppet_resource_should_show('idle_timeout', '00:20:00', resource('iis_application_pool', pool_name))
        puppet_resource_should_show('load_user_profile', :false, resource('iis_application_pool', pool_name))
        puppet_resource_should_show('logon_type', 'LogonBatch', resource('iis_application_pool', pool_name))
        puppet_resource_should_show('manual_group_membership', :false, resource('iis_application_pool', pool_name))
        puppet_resource_should_show('max_processes', '1', resource('iis_application_pool', pool_name))
        puppet_resource_should_show('pinging_enabled', :true, resource('iis_application_pool', pool_name))
        puppet_resource_should_show('ping_interval', '00:00:30', resource('iis_application_pool', pool_name))
        puppet_resource_should_show('ping_response_time', '00:01:30', resource('iis_application_pool', pool_name))
        puppet_resource_should_show('set_profile_environment', :true, resource('iis_application_pool', pool_name))
        puppet_resource_should_show('shutdown_time_limit', '00:01:30', resource('iis_application_pool', pool_name))
        puppet_resource_should_show('startup_time_limit', '00:01:30', resource('iis_application_pool', pool_name))

        # Properties introduced in IIS 8.5 (Server 2012R2 - Kernel 6.3)
        unless ['6.2', '6.1'].include?(fact('kernelmajversion'))
          puppet_resource_should_show('idle_timeout_action', 'Terminate', resource('iis_application_pool', pool_name))
          puppet_resource_should_show('log_event_on_process_model', 'IdleTimeout', resource('iis_application_pool', pool_name))
        end
      end

      it 'removes app poll' do
        remove_app_pool(pool_name)
      end
    end

    context 'with a password wrapped in Sensitive() defined' do
      if get_puppet_version.to_i < 5
        skip 'is skipped due to version being lower than puppet 5'
      else
        pool_name = define_pool_name

        describe 'applies the manifest twice' do
          manifest = <<-HERE
            iis_application_pool { '#{pool_name}':
              ensure    => 'present',
              user_name => 'user',
              password  => Sensitive('#@\\\'454sdf'),
            }
          HERE

          it_behaves_like 'an idempotent resource', manifest
        end

        context 'when puppet resource is run' do
          puppet_resource_should_show('ensure', 'present', resource('iis_application_pool', pool_name))
          puppet_resource_should_show('user_name', 'user', resource('iis_application_pool', pool_name))
          puppet_resource_should_show('password', '#@\\\'454sdf', resource('iis_application_pool', pool_name))

          it 'removes app poll' do
            remove_app_pool(pool_name)
          end
        end
      end
    end

    context 'with invalid' do
      pool_name = define_pool_name
      context 'state parameter defined' do
        # pool_name = define_pool_name
        describe 'applies a failing manifest' do
          manifest = <<-HERE
                iis_application_pool { '#{pool_name}':
                  ensure  => 'present',
                  state   => 'AnotherTypo'
                }
                HERE

          it_behaves_like 'a failing manifest', manifest
        end

        context 'when puppet resource is run' do
          puppet_resource_should_show('ensure', 'absent', resource('iis_application_pool', pool_name))
        end

        it 'removes app poll' do
          remove_app_pool(pool_name)
        end
      end

      context 'managed_pipeline_mode parameter defined' do
        pool_name = define_pool_name
        describe 'applies a failing manifest' do
          manifest = <<-HERE
                iis_application_pool { '#{pool_name}':
                  ensure              => 'present',
                  managed_pipeline_mode => 'ClassicTypo'
                }
                HERE

          it_behaves_like 'a failing manifest', manifest
        end

        context 'when puppet resource is run' do
          puppet_resource_should_show('ensure', 'absent', resource('iis_application_pool', pool_name))
        end

        it 'removes app poll' do
          remove_app_pool(pool_name)
        end
      end
    end
  end

  context 'when starting a stopped application pool' do
    pool_name = define_pool_name
    create_app_pool(pool_name)
    stop_app_pool(pool_name)

    describe 'applies the manifest twice' do
      manifest = <<-HERE
      iis_application_pool { '#{pool_name}':
        ensure  => 'present',
        state   => 'Started'
      }
      HERE

      it_behaves_like 'an idempotent resource', manifest
    end

    context 'when puppet resource is run' do
      puppet_resource_should_show('ensure', 'present', resource('iis_application_pool', pool_name))
      puppet_resource_should_show('state', 'Started', resource('iis_application_pool', pool_name))
    end

    it 'removes app poll' do
      remove_app_pool(pool_name)
    end
  end

  context 'when removing an application pool' do
    pool_name = define_pool_name

    create_app_pool(pool_name)
    describe 'applies the manifest twice' do
      manifest = <<-HERE
      iis_application_pool { '#{pool_name}':
        ensure => 'absent'
        }
      HERE

      it_behaves_like 'an idempotent resource', manifest
    end

    context 'when puppet resource is run' do
      puppet_resource_should_show('ensure', 'absent', resource('iis_application_pool', pool_name))
    end
  end

  context 'when application pool restart_memory_limit set' do
    pool_name = define_pool_name
    create_app_pool(pool_name)
    stop_app_pool(pool_name)

    describe 'applies the manifest twice' do
      manifest = <<-HERE
      iis_application_pool { '#{pool_name}':
        ensure               => 'present',
        state                => 'Started',
        restart_memory_limit => '3500000',
       }
       HERE

      it_behaves_like 'an idempotent resource', manifest
    end

    context 'when puppet resource is run' do
      puppet_resource_should_show('ensure', 'present', resource('iis_application_pool', pool_name))
      puppet_resource_should_show('state', 'Started', resource('iis_application_pool', pool_name))
      puppet_resource_should_show('restart_memory_limit', '3500000', resource('iis_application_pool', pool_name))
    end

    it 'removes app poll' do
      remove_app_pool(pool_name)
    end
  end

  context 'when building a complex application' do
    pool_name = define_pool_name
    describe 'applies the manifest twice' do
      manifest = <<-HERE
        iis_application_pool { '#{pool_name}':
          ensure                           => 'present',
          state                            => 'Started',
          restart_memory_limit             => '3500000',
          managed_pipeline_mode            => 'Integrated',
          managed_runtime_version          => 'v4.0',
          auto_start                       => true,
          enable32_bit_app_on_win64        => false,
          enable_configuration_override    => true,
          pass_anonymous_token             => true,
          start_mode                       => 'OnDemand',
          queue_length                     => '1000',
          cpu_action                       => 'NoAction',
          cpu_limit                        => '100000',
          cpu_reset_interval               => '00:05:00',
          cpu_smp_affinitized              => false,
          cpu_smp_processor_affinity_mask  => '4294967295',
          cpu_smp_processor_affinity_mask2 => '4294967295',
          identity_type                    => 'ApplicationPoolIdentity',
          idle_timeout                     => '00:20:00',
          load_user_profile                => false,
          logon_type                       => 'LogonBatch',
          manual_group_membership          => false,
          max_processes                    => '1',
          pinging_enabled                  => true,
          ping_interval                    => '00:00:30',
          ping_response_time               => '00:01:30',
          set_profile_environment          => true,
          shutdown_time_limit              => '00:01:30',
          startup_time_limit               => '00:01:30',
          orphan_action_exe                => 'foo.exe',
          orphan_action_params             => '-wakka',
          orphan_worker_process            => true,
        }
    HERE
      it_behaves_like 'an idempotent resource', manifest
    end

    context 'when puppet resource is run' do
      puppet_resource_should_show('ensure', 'present', resource('iis_application_pool', pool_name))
      puppet_resource_should_show('state', 'Started', resource('iis_application_pool', pool_name))
      puppet_resource_should_show('restart_memory_limit', '3500000', resource('iis_application_pool', pool_name))
      puppet_resource_should_show('managed_pipeline_mode', 'Integrated', resource('iis_application_pool', pool_name))
      puppet_resource_should_show('managed_runtime_version', 'v4.0', resource('iis_application_pool', pool_name))
      puppet_resource_should_show('auto_start', :true, resource('iis_application_pool', pool_name))
      puppet_resource_should_show('enable32_bit_app_on_win64', :false, resource('iis_application_pool', pool_name))
      puppet_resource_should_show('enable_configuration_override', :true, resource('iis_application_pool', pool_name))
      puppet_resource_should_show('pass_anonymous_token', :true, resource('iis_application_pool', pool_name))
      puppet_resource_should_show('start_mode', 'OnDemand', resource('iis_application_pool', pool_name))
      puppet_resource_should_show('queue_length', '1000', resource('iis_application_pool', pool_name))
      puppet_resource_should_show('cpu_action', 'NoAction', resource('iis_application_pool', pool_name))
      puppet_resource_should_show('cpu_limit', '100000', resource('iis_application_pool', pool_name))
      puppet_resource_should_show('cpu_reset_interval', '00:05:00', resource('iis_application_pool', pool_name))
      puppet_resource_should_show('cpu_smp_affinitized', :false, resource('iis_application_pool', pool_name))
      puppet_resource_should_show('cpu_smp_processor_affinity_mask', '4294967295', resource('iis_application_pool', pool_name))
      puppet_resource_should_show('cpu_smp_processor_affinity_mask2', '4294967295', resource('iis_application_pool', pool_name))
      puppet_resource_should_show('identity_type', 'ApplicationPoolIdentity', resource('iis_application_pool', pool_name))
      puppet_resource_should_show('idle_timeout', '00:20:00', resource('iis_application_pool', pool_name))
      puppet_resource_should_show('load_user_profile', :false, resource('iis_application_pool', pool_name))
      puppet_resource_should_show('logon_type', 'LogonBatch', resource('iis_application_pool', pool_name))
      puppet_resource_should_show('manual_group_membership', :false, resource('iis_application_pool', pool_name))
      puppet_resource_should_show('max_processes', '1', resource('iis_application_pool', pool_name))
      puppet_resource_should_show('pinging_enabled', :true, resource('iis_application_pool', pool_name))
      puppet_resource_should_show('ping_interval', '00:00:30', resource('iis_application_pool', pool_name))
      puppet_resource_should_show('ping_response_time', '00:01:30', resource('iis_application_pool', pool_name))
      puppet_resource_should_show('set_profile_environment', :true, resource('iis_application_pool', pool_name))
      puppet_resource_should_show('shutdown_time_limit', '00:01:30', resource('iis_application_pool', pool_name))
      puppet_resource_should_show('startup_time_limit', '00:01:30', resource('iis_application_pool', pool_name))
    end

    it 'removes app poll' do
      remove_app_pool(pool_name)
    end
  end
end
