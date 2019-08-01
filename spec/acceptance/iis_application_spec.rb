require 'spec_helper_acceptance'

describe 'iis_application' do
  before(:all) do
    # Remove 'Default Web Site' to start from a clean slate
    # remove_all_sites
    remove_all_sites
  end

  context 'when creating an application' do
    context 'with normal parameters' do
      site_name = define_pool_name
      app_name = define_pool_name
      create_path('C:\inetpub\basic')

      describe 'applies the manifest twice' do
        manifest = <<-HERE
          iis_site { '#{site_name}':
            ensure          => 'started',
            physicalpath    => 'C:\\inetpub\\basic',
            applicationpool => 'DefaultAppPool',
          }
          iis_application { '#{app_name}':
            ensure       => 'present',
            sitename     => '#{site_name}',
            physicalpath => 'C:\\inetpub\\basic',
          }
        HERE

        it_behaves_like 'an idempotent resource', manifest
      end

      context 'when puppet resource is run' do
        result = on(default, puppet('resource', 'iis_application', "#{site_name}\\\\#{app_name}"))

        include_context 'with a puppet resource run'
        puppet_resource_should_show('physicalpath', 'C:\inetpub\basic', result)
        puppet_resource_should_show('applicationpool', 'DefaultAppPool', result)

        context 'when case is changed in a manifest' do
          manifest = <<-HERE
              iis_application { '#{app_name}':
                ensure       => 'present',
                sitename     => '#{site_name}',
                # Change the capitalization of the T to see if it breaks.
                physicalpath => 'C:\\ineTpub\\basic',
              }
            HERE

          it 'runs with no changes' do
            execute_manifest(manifest, catch_changes: true)
          end
        end
      end

      it 'removes app' do
        remove_app(app_name)
        # remove_all_sites
      end
    end

    context 'with virtual_directory' do
      site_name = define_pool_name
      app_name = define_pool_name
      create_site(site_name, true)
      create_path('C:\inetpub\vdir')
      create_virtual_directory(site_name, app_name, 'C:\inetpub\vdir')

      describe 'applies the manifest twice' do
        manifest = <<-HERE
          iis_application { '#{site_name}\\#{app_name}':
            ensure            => 'present',
            virtual_directory => 'IIS:\\Sites\\#{site_name}\\#{app_name}',
          }
        HERE

        it_behaves_like 'an idempotent resource', manifest
      end

      context 'when puppet resource is run' do
        result = on(default, puppet('resource', 'iis_application', "#{site_name}\\\\#{app_name}"))

        include_context 'with a puppet resource run'
        puppet_resource_should_show('physicalpath', 'C:\inetpub\vdir', result)
        puppet_resource_should_show('applicationpool', 'DefaultAppPool', result)
      end

      it 'removes app' do
        remove_app(app_name)
        # remove_all_sites
      end
    end

    context 'with nested virtual directory' do
      site_name = define_pool_name
      app_name = define_pool_name
      create_site(site_name, true)
      create_path("c:\\inetpub\\wwwroot\\subFolder\\#{app_name}")

      describe 'applies the manifest twice' do
        manifest = <<-HERE
          iis_application{'subFolder/#{app_name}':
            ensure => 'present',
            applicationname => 'subFolder/#{app_name}',
            physicalpath => 'c:\\inetpub\\wwwroot\\subFolder\\#{app_name}',
            sitename => '#{site_name}'
          }
        HERE

        it_behaves_like 'an idempotent resource', manifest
      end

      describe 'application validation' do
        it 'creates the correct application' do
          result = on(default, puppet('resource', 'iis_application', "#{site_name}\\\\subFolder/#{app_name}"))
          expect(result.stdout).to match(/iis_application { '#{site_name}\\subFolder\/#{app_name}':/)
          expect(result.stdout).to match(%r{ensure\s*=> 'present',})
        end
      end

      it 'removes all' do
        remove_app(app_name)
        # remove_all_sites
      end
    end

    context 'with nested virtual directory and single namevar' do
      site_name = define_pool_name
      app_name = define_pool_name
      create_site(site_name, true)
      create_path("c:\\inetpub\\wwwroot\\subFolder\\#{app_name}")

      describe 'applies the manifest twice' do
        manifest = <<-HERE
          iis_application{'subFolder/#{app_name}':
            ensure => 'present',
            physicalpath => 'c:\\inetpub\\wwwroot\\subFolder\\#{app_name}',
            sitename => '#{site_name}'
          }
        HERE

        it_behaves_like 'an idempotent resource', manifest
      end

      describe 'application validation' do
        it 'creates the correct application' do
          result = on(default, puppet('resource', 'iis_application', "#{site_name}\\\\subFolder/#{app_name}"))
          expect(result.stdout).to match(/iis_application { '#{site_name}\\subFolder\/#{app_name}':/)
          expect(result.stdout).to match(%r{ensure\s*=> 'present',})
        end
      end

      it 'removes all' do
        remove_app(app_name)
        # remove_all_sites
      end
    end

    context 'with forward slash virtual directory name format' do
      context 'with a leading slash' do
        site_name = define_pool_name
        app_name = define_pool_name
        create_site(site_name, true)
        create_path("c:\\inetpub\\wwwroot\\subFolder\\#{app_name}")

        describe 'applies the manifest twice' do
          manifest = <<-HERE
            iis_application{'subFolder/#{app_name}':
              ensure => 'present',
              applicationname => '/subFolder/#{app_name}',
              physicalpath => 'c:\\inetpub\\wwwroot\\subFolder\\#{app_name}',
              sitename => '#{site_name}'
            }
          HERE

          it_behaves_like 'an idempotent resource', manifest
        end

        it 'removes all' do
          remove_app(app_name)
          remove_all_sites
        end
      end
    end

    context 'with backward slash virtual directory name format' do
      site_name = define_pool_name
      app_name = define_pool_name
      create_site(site_name, true)
      create_path("c:\\inetpub\\wwwroot\\subFolder\\#{app_name}")

      describe 'applies the manifest twice' do
        manifest = <<-HERE
            iis_application{'subFolder\\#{app_name}':
              ensure => 'present',
              applicationname => 'subFolder/#{app_name}',
              physicalpath => 'c:\\inetpub\\wwwroot\\subFolder\\#{app_name}',
              sitename => '#{site_name}'
            }
        HERE

        it_behaves_like 'an idempotent resource', manifest
      end

      it 'removes all' do
        remove_app(app_name)
        remove_all_sites
      end
    end

    context 'with two level nested virtual directory' do
      site_name = define_pool_name
      app_name = define_pool_name
      create_site(site_name, true)
      create_path("c:\\inetpub\\wwwroot\\subFolder\\sub2\\#{app_name}")

      describe 'applies the manifest twice' do
        manifest = <<-HERE
          iis_application{'subFolder/sub2/#{app_name}':
            ensure => 'present',
            applicationname => 'subFolder/sub2/#{app_name}',
            physicalpath => 'c:\\inetpub\\wwwroot\\subFolder\\sub2\\#{app_name}',
            sitename => '#{site_name}'
          }
        HERE

        it_behaves_like 'an idempotent resource', manifest
      end

      describe 'application validation' do
        it 'creates the correct application' do
          result = on(default, puppet('resource', 'iis_application', "#{site_name}\\\\subFolder/sub2/#{app_name}"))
          expect(result.stdout).to match(/iis_application { '#{site_name}\\subFolder\/sub2\/#{app_name}':/)
          expect(result.stdout).to match(%r{ensure\s*=> 'present',})
        end
      end

      it 'removes all' do
        remove_app(app_name)
        remove_all_sites
      end
    end
  end

  context 'when setting' do
    # skip 'sslflags - blocked by MODULES-5561' do
    site_name = define_pool_name
    app_name = define_pool_name
    create_site(site_name, true)
    create_path('C:\inetpub\wwwroot')
    create_path('C:\inetpub\modify')
    site_hostname = 'www.puppet.local'
    thumbprint = create_selfsigned_cert(site_hostname)
    create_app(site_name, app_name, 'C:\inetpub\wwwroot')

    describe 'applies the manifest twice' do
      manifest = <<-HERE
        iis_site { '#{site_name}':
          ensure          => 'started',
          physicalpath    => 'C:\\inetpub\\wwwroot',
          applicationpool => 'DefaultAppPool',
          bindings        => [
            {
              'bindinginformation'   => '*:80:#{site_hostname}',
              'protocol'             => 'http',
            },
            {
              'bindinginformation'   => '*:443:#{site_hostname}',
              'protocol'             => 'https',
              'certificatestorename' => 'MY',
              'certificatehash'      => '#{thumbprint.downcase}',
              'sslflags'             => 0,
            },
          ],
        }
        iis_application { '#{app_name}':
          ensure       => 'present',
          sitename     => '#{site_name}',
          physicalpath => 'C:\\inetpub\\modify',
          sslflags     => ['Ssl','SslRequireCert'],
        }
      HERE

      it_behaves_like 'an idempotent resource', manifest
    end

    describe 'authenticationinfo' do
      site_name = define_pool_name
      app_name = define_pool_name
      create_site(site_name, true)
      create_path('C:\inetpub\wwwroot')
      create_path('C:\inetpub\auth')
      create_app(site_name, app_name, 'C:\inetpub\auth')

      describe 'applies the manifest twice' do
        manifest = <<-HERE
          iis_application { '#{app_name}':
            ensure       => 'present',
            sitename     => '#{site_name}',
            physicalpath => 'C:\\inetpub\\auth',
            authenticationinfo => {
              'basic'     => true,
              'anonymous' => false,
            },
          }
        HERE

        it_behaves_like 'an idempotent resource', manifest
      end
    end

    describe 'applicationpool' do
      site_name = define_pool_name
      app_name = define_pool_name
      create_site(site_name, true)
      create_path('C:\inetpub\wwwroot')
      create_path('C:\inetpub\auth')
      create_app(site_name, app_name, 'C:\inetpub\auth')
      create_app_pool('foo_pool')

      describe 'applies the manifest twice' do
        manifest = <<-HERE
          iis_application { '#{app_name}':
            ensure       => 'present',
            sitename     => '#{site_name}',
            physicalpath => 'C:\\inetpub\\auth',
            applicationpool => 'foo_pool'
          }
        HERE

        it_behaves_like 'an idempotent resource', manifest
      end
    end
  end

  context 'when removing an application' do
    site_name = define_pool_name
    app_name = define_pool_name
    create_site(site_name, true)
    create_path('C:\inetpub\remove')
    create_virtual_directory(site_name, app_name, 'C:\inetpub\remove')
    create_app(site_name, app_name, 'C:\inetpub\remove')

    describe 'applies the manifest twice' do
      manifest = <<-HERE
        iis_application { '#{app_name}':
          ensure       => 'absent',
          sitename     => '#{site_name}',
          physicalpath => 'C:\\inetpub\\remove',
        }
      HERE

      it_behaves_like 'an idempotent resource', manifest
    end

    context 'when puppet resource is run' do
      result = on(default, puppet('resource', 'iis_application', "#{site_name}\\\\#{app_name}"))

      include_context 'with a puppet resource run'
      puppet_resource_should_show('ensure', 'absent', result)
    end

    it 'removes app' do
      remove_app(app_name)
    end
  end

  context 'with multiple sites with same application name' do
    remove_all_sites
    site_name = define_pool_name
    site_name2 = define_pool_name
    app_name = define_pool_name
    create_path("C:\\inetpub\\#{site_name}\\#{app_name}")
    create_path("C:\\inetpub\\#{site_name2}\\#{app_name}")

    describe 'applies the manifest twice' do
      manifest = <<-HERE
        iis_site { '#{site_name}':
          ensure          => 'started',
          physicalpath    => 'C:\\inetpub\\#{site_name}',
          applicationpool => 'DefaultAppPool',
          bindings        => [
          {
            'bindinginformation' => '*:8081:',
            'protocol'           => 'http',
          }]
        }
        iis_application { '#{site_name}\\#{app_name}':
          ensure            => 'present',
          sitename        => '#{site_name}',
          physicalpath => 'C:\\inetpub\\#{site_name}\\#{app_name}',
        }
        iis_site { '#{site_name2}':
          ensure          => 'started',
          physicalpath    => 'C:\\inetpub\\#{site_name2}',
          applicationpool => 'DefaultAppPool',
        }
        iis_application { '#{site_name2}\\#{app_name}':
          ensure            => 'present',
          sitename        => '#{site_name2}',
          physicalpath => 'C:\\inetpub\\#{site_name2}\\#{app_name}',
        }
        HERE

      it_behaves_like 'an idempotent resource', manifest
    end

    it 'contains two sites with the same app name' do
      on(default, puppet('resource', 'iis_application', "#{site_name}\\\\#{app_name}")) do |result|
        expect(result.stdout).to match(%r{#{site_name}\\#{app_name}})
        expect(result.stdout).to match(%r{ensure\s*=> 'present',})
        expect(result.stdout).to match %r{C:\\inetpub\\#{site_name}\\#{app_name}}
        expect(result.stdout).to match %r{applicationpool\s*=> 'DefaultAppPool'}
      end
      on(default, puppet('resource', 'iis_application', "#{site_name2}\\\\#{app_name}")) do |result|
        expect(result.stdout).to match(%r{#{site_name2}\\#{app_name}})
        expect(result.stdout).to match(%r{ensure\s*=> 'present',})
        expect(result.stdout).to match %r{C:\\inetpub\\#{site_name2}\\#{app_name}}
        expect(result.stdout).to match %r{applicationpool\s*=> 'DefaultAppPool'}
      end
    end

    it 'removes app' do
      remove_app(app_name)
      remove_all_sites
    end
  end
end
