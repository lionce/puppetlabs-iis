require 'spec_helper_acceptance'

describe 'iis_virtual_directory' do
  it 'create ne site' do
    before(:all) do
      # Remove 'Default Web Site' to start from a clean slate
      remove_all_sites
    end

    site_name = define_pool_name
    create_site(site_name, true)
  end

  after(:all) do
    remove_all_sites
  end

  context 'when configuring a virtual directory' do
    context 'with default parameters' do
      virt_dir_name = define_pool_name
      site_name = define_pool_name
      describe 'applies the manifest twice' do
        manifest = <<-HERE
          file{ 'c:/foo':
            ensure => 'directory'
          }->
          file{ 'c:/foo2':
          ensure => 'directory'
          }->
          iis_virtual_directory { '#{virt_dir_name}':
            ensure       => 'present',
            sitename     => '#{site_name}',
            physicalpath => 'c:\\foo'
          }
        HERE

        it_behaves_like 'an idempotent resource', manifest
      end

      context 'when puppet resource is run' do
        puppet_resource_should_show('ensure', 'present', resource('iis_virtual_directory', virt_dir_name))

        context 'when capitalization of paths change' do
          manifest = <<-HERE
              iis_virtual_directory { '#{virt_dir_name}':
                ensure       => 'present',
                sitename     => '#{site_name}',
                # Change capitalization to see if it breaks idempotency
                physicalpath => 'c:\\Foo'
              }
            HERE

          it 'runs with no changes' do
            execute_manifest(manifest, catch_changes: true)
          end
        end
      end

      context 'when physical path changes' do
        describe 'applies the manifest twice' do
          manifest = <<-HERE
          iis_virtual_directory { '#{virt_dir_name}':
            ensure       => 'present',
            sitename     => '#{site_name}',
            physicalpath => 'c:\\foo2'
          }
          HERE

          it_behaves_like 'an idempotent resource', manifest
        end

        context 'when puppet resource is run' do
          result = resource('iis_virtual_directory', virt_dir_name)

          puppet_resource_should_show('physicalpath', 'c:\\foo2', result)
        end
      end

      it 'removes vrt dir' do
        remove_vdir(virt_dir_name)
      end
    end

    context 'with a password wrapped in Sensitive()' do
      if get_puppet_version.to_i < 5
        skip 'is skipped due to version being lower than puppet 5'
      else
        virt_dir_name = define_pool_name
        describe 'applies the manifest twice' do
          manifest = <<-HERE
            file{ 'c:/foo':
              ensure => 'directory'
            }->
            iis_virtual_directory { '#{virt_dir_name}':
              ensure       => 'present',
              sitename     => '#{site_name}',
              physicalpath => 'c:\\foo',
              user_name    => 'user',
              password     => Sensitive('#@\\\'454sdf'),
            }
          HERE

          it_behaves_like 'an idempotent resource', manifest
        end

        context 'when puppet resource is run' do
          puppet_resource_should_show('ensure', 'present', resource('iis_virtual_directory', virt_dir_name))
          puppet_resource_should_show('user_name', 'user', resource('iis_virtual_directory', virt_dir_name))
          puppet_resource_should_show('password', '#@\\\'454sdf', resource('iis_virtual_directory', virt_dir_name))
        end

        it 'removes all' do
          remove_vdir(virt_dir_name)
        end
      end
    end

    context 'can remove virtual directory' do
      before(:all) do
        virt_dir_name = define_pool_name
        create_path('c:/foo')
        create_vdir(virt_dir_name, 'foo', 'c:/foo')
        manifest = <<-HERE
          iis_virtual_directory { '#{virt_dir_name}':
            ensure       => 'absent'
          }
        HERE
      end

      it_behaves_like 'an idempotent resource'

      context 'when puppet resource is run' do
        before(:all) do
          result = resource('iis_virtual_directory', virt_dir_name)
        end

        puppet_resource_should_show('ensure', 'absent')
      end

      after(:all) do
        remove_vdir(virt_dir_name)
      end
    end

    context 'name allows slashes' do
      context 'simple case' do
        before(:all) do
          virt_dir_name = define_pool_name
          create_path('c:\inetpub\test_site')
          create_path('c:\inetpub\test_vdir')
          create_path('c:\inetpub\deeper')
          create_site(site_name, true)
          manifest = <<-HERE
          iis_virtual_directory{ "test_vdir":
            ensure       => 'present',
            sitename     => "#{site_name}",
            physicalpath => 'c:\\inetpub\\test_vdir',
          }->
          iis_virtual_directory { 'test_vdir\deeper':
            name         => 'test_vdir\deeper',
            ensure	     => 'present',
            sitename     => '#{site_name}',
            physicalpath => 'c:\\inetpub\\deeper',
          }
          HERE
        end

        it_behaves_like 'an idempotent resource'

        it 'removes all' do
          remove_vdir(virt_dir_name)
        end
      end
    end

    context 'with invalid' do
      context 'physicalpath parameter defined' do
        before(:all) do
          virt_dir_name = define_pool_name
          manifest = <<-HERE
          iis_virtual_directory { '#{virt_dir_name}':
            ensure       => 'present',
            sitename     => '#{site_name}',
            physicalpath => 'c:\\wakka'
          }
          HERE
        end

        it_behaves_like 'a failing manifest'

        context 'when puppet resource is run' do
          before(:all) do
            result = resource('iis_virtual_directory', virt_dir_name)
          end

          puppet_resource_should_show('ensure', 'absent')
        end

        it 'removes all' do
          remove_vdir(virt_dir_name)
        end
      end

      context 'physicalpath parameter not defined' do
        before(:all) do
          virt_dir_name = define_pool_name
          manifest = <<-HERE
          iis_virtual_directory { '#{virt_dir_name}':
            ensure       => 'present',
            sitename     => '#{site_name}'
          }
          HERE
        end

        it_behaves_like 'a failing manifest'

        context 'when puppet resource is run' do
          before(:all) do
            result = resource('iis_virtual_directory', virt_dir_name)
          end

          puppet_resource_should_show('ensure', 'absent')
        end

        it 'removes all' do
          remove_vdir(virt_dir_name)
        end
      end
    end
  end
end
