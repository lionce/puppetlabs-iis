require 'spec_helper_acceptance'

describe 'iis_site' do
  before(:all) do
    # Remove 'Default Web Site' to start from a clean slate
    remove_all_sites
  end

  context 'when configuring a website' do
    # context 'with basic required parameters' do
    #   create_path('C:\inetpub\basic')
    #   site_name = define_pool_name

    #   describe 'applies the manifest twice' do
    #     manifest = <<-HERE
    #       iis_site { '#{site_name}':
    #         ensure          => 'started',
    #         physicalpath    => 'C:\\inetpub\\basic',
    #         applicationpool => 'DefaultAppPool',
    #       }
    #     HERE

    #     puts 'before manifest' + manifest
    #     it_behaves_like 'an idempotent resource', manifest
    #     puts 'afetr apply manifest in before all'
    #   end

    #   context 'when puppet resource is run' do
    #     describe "property has the correct value" do
    #       puppet_resource_should_show('ensure', 'started', resource('iis_site', site_name))
    #       puppet_resource_should_show('physicalpath', 'C:\inetpub\basic', resource('iis_site', site_name))
    #       puppet_resource_should_show('applicationpool', 'DefaultAppPool', resource('iis_site', site_name))
    #     end
    #   end

    #   after(:all) do
    #     remove_all_sites
    #   end
    # end

    context 'with all parameters specified' do
      context 'using W3C log format, logflags and logtruncatesize' do
        create_path('C:\inetpub\new')
        site_name = define_pool_name
        thumbprint = create_selfsigned_cert('www.puppet.local')
        describe 'apply manifest 3 times' do
          manifest = <<-HERE
            iis_site { '#{site_name}':
              ensure               => 'started',
              applicationpool      => 'DefaultAppPool',
              enabledprotocols     => 'https',
              bindings             => [
                {
                  'bindinginformation'   => '*:8080:',
                  'protocol'             => 'http',
                },
                {
                  'bindinginformation'   => '*:8084:domain.test',
                  'protocol'             => 'http',
                },
                {
                  'bindinginformation'   => '*:443:www.puppet.local',
                  'certificatehash'      => '#{thumbprint}',
                  'certificatestorename' => 'MY',
                  'protocol'             => 'https',
                  'sslflags'             => 1,
                },
              ],
              limits               => {
                connectiontimeout => 120,
                maxbandwidth      => 4294967200,
                maxconnections    => 4294967200,
              },
              logflags             => ['ClientIP', 'Date', 'Time', 'UserName'],
              logformat            => 'W3C',
              loglocaltimerollover => false,
              logpath              => 'C:\\inetpub\\logs\\NewLogFiles',
              logtruncatesize      => 2000000,
              physicalpath         => 'C:\\inetpub\\new',
            }
          HERE

          # it_behaves_like 'an idempotent resource'

          # Idempotency is broken in this module. Only by the third run will you
          # know if you have an idempotency bug in the module. If on the third
          # run you still have changes happening, that's when there's a problem.
          # This bug will most likely be squashed whenever changes are made to fix
          # MODULES-5561. Even thought that ticket refers to iis_applications and
          # not sites, the issue is with how the module itself handles configuring
          # resources.

          # it 'runs without errors' do
          execute_manifest(manifest, catch_failures: true)
          # end

          # it 'has changes on the second run' do
          execute_manifest(manifest, catch_changes: false)
          # end

          # it 'runs the third time without errors or changes' do
          execute_manifest(manifest, catch_failures: true)
          # end
        end

        context 'when puppet resource is run' do
          describe 'property has the correct value' do
            result = resource('iis_site', site_name)

            # puppet_resource_should_show('ensure','started', resource('iis_site', site_name))
            # puppet_resource_should_show('applicationpool','DefaultAppPool',  resource('iis_site', site_name))
            puppet_resource_should_show('enabledprotocols', 'https', resource('iis_site', site_name))
            # puppet_resource_should_show('bindings',             [
            #    {
            #      'bindinginformation'   => '*:8080:',
            #      'certificatehash'      => '',
            #      'certificatestorename' => '',
            #      'protocol'             => 'http',
            #      'sslflags'             => '0',
            #    },
            #    {
            #      'bindinginformation'   => '*:8084:domain.test',
            #      'certificatehash'      => '',
            #      'certificatestorename' => '',
            #      'protocol'             => 'http',
            #      'sslflags'             => '0',
            #    }
            #  ]
            # )
            # puppet_resource_should_show('logflags',['ClientIP', 'Date', 'Time', 'UserName'], resource('iis_site', site_name))
            # puppet_resource_should_show('logformat','W3C', resource('iis_site', site_name))
            # puppet_resource_should_show('loglocaltimerollover', 'false', resource('iis_site', site_name))
            # puppet_resource_should_show('logpath','C:\\inetpub\\logs\\NewLogFiles', resource('iis_site', site_name))
            # puppet_resource_should_show('logtruncatesize','2000000', resource('iis_site', site_name))
            # puppet_resource_should_show('physicalpath','C:\\inetpub\\new', resource('iis_site', site_name))
            # puppet_resource_should_show('bindinginformation', '\*:443:www.puppet.local', resource('iis_site', site_name))
          end

          it 'has a binding to 443' do
            expect(resource('iis_site', site_name).stdout).to match(%r{'bindinginformation' => '\*:443:www.puppet.local'})
          end
          # expect(result.stdout).to match(regex)

          context 'when capitalization is changed in path parameters' do
            manifest = <<-HERE
                iis_site { '#{@site_name}':
                  ensure               => 'started',
                  # Change capitalization to see if it break idempotency
                  logpath              => 'C:\\ineTpub\\logs\\NewLogFiles',
                  physicalpath         => 'C:\\ineTpub\\new',
                }
              HERE

            it 'runs with no changes' do
              execute_manifest(manifest, catch_changes: true)
            end
          end
        end

        after(:all) do
          remove_all_sites
        end
      end
    end
  end
end

# require 'spec_helper_acceptance'

# describe 'iis_site' do
#     # Remove 'Default Web Site' to start from a clean slate
#     remove_all_sites

#   context 'when configuring a website' do
#     context 'with basic required parameters' do
#       require 'pry'
#       binding.pry
#       create_path('C:\inetpub\basic')
#       site_name = define_pool_name

#       describe 'applies the manifest twice' do
#         manifest = <<-HERE
#           iis_site { '#{site_name}':
#             ensure          => 'started',
#             physicalpath    => 'C:\\inetpub\\basic',
#             applicationpool => 'DefaultAppPool',
#           }
#         HERE

#         it_behaves_like 'an idempotent resource', manifest
#       end

#       context 'when puppet resource is run' do
#         result = resource('iis_site', site_name)
#         puppet_resource_should_show('ensure', 'started', result)
#         puppet_resource_should_show('physicalpath', 'C:\inetpub\basic', result)
#         puppet_resource_should_show('applicationpool', 'DefaultAppPool', result)
#       end

#       it 'removes app sites' do
#         #remove_all_sites
#       end
#     end

#     context 'with all parameters specified' do
#       context 'using W3C log format, logflags and logtruncatesize' do
#         create_path('C:\inetpub\new')
#         site_name = define_pool_name
#         thumbprint = create_selfsigned_cert('www.puppet.local')

#         describe 'applies the manifest 3 times' do
#           manifest = <<-HERE
#             iis_site { '#{site_name}':
#               ensure               => 'started',
#               applicationpool      => 'DefaultAppPool',
#               enabledprotocols     => 'https',
#               bindings             => [
#                 {
#                   'bindinginformation'   => '*:8080:',
#                   'protocol'             => 'http',
#                 },
#                 {
#                   'bindinginformation'   => '*:8084:domain.test',
#                   'protocol'             => 'http',
#                 },
#                 {
#                   'bindinginformation'   => '*:443:www.puppet.local',
#                   'certificatehash'      => '#{thumbprint}',
#                   'certificatestorename' => 'MY',
#                   'protocol'             => 'https',
#                   'sslflags'             => 1,
#                 },
#               ],
#               limits               => {
#                 connectiontimeout => 120,
#                 maxbandwidth      => 4294967200,
#                 maxconnections    => 4294967200,
#               },
#               logflags             => ['ClientIP', 'Date', 'Time', 'UserName'],
#               logformat            => 'W3C',
#               loglocaltimerollover => false,
#               logpath              => 'C:\\inetpub\\logs\\NewLogFiles',
#               logtruncatesize      => 2000000,
#               physicalpath         => 'C:\\inetpub\\new',
#             }
#           HERE

#         # it_behaves_like 'an idempotent resource'

#         # Idempotency is broken in this module. Only by the third run will you
#         # know if you have an idempotency bug in the module. If on the third
#         # run you still have changes happening, that's when there's a problem.
#         # This bug will most likely be squashed whenever changes are made to fix
#         # MODULES-5561. Even thought that ticket refers to iis_applications and
#         # not sites, the issue is with how the module itself handles configuring
#         # resources.

#         it 'runs without errors' do
#           execute_manifest(manifest, catch_failures: true)
#         end

#         it 'has changes on the second run' do
#           execute_manifest(manifest, catch_changes: false)
#         end

#         it 'runs the third time without errors or changes' do
#           execute_manifest(manifest, catch_failures: true)
#         end
#       end

#         context 'when puppet resource is run' do
#           result = resource('iis_site', site_name)
#           puppet_resource_should_show('ensure', 'started', result)
#           puppet_resource_should_show('applicationpool', 'DefaultAppPool', result)
#           puppet_resource_should_show('enabledprotocols', 'https', result)
#           # puppet_resource_should_show('bindings',             [
#           #    {
#           #      'bindinginformation'   => '*:8080:',
#           #      'certificatehash'      => '',
#           #      'certificatestorename' => '',
#           #      'protocol'             => 'http',
#           #      'sslflags'             => '0',
#           #    },
#           #    {
#           #      'bindinginformation'   => '*:8084:domain.test',
#           #      'certificatehash'      => '',
#           #      'certificatestorename' => '',
#           #      'protocol'             => 'http',
#           #      'sslflags'             => '0',
#           #    }
#           #  ]
#           # )
#           puppet_resource_should_show('logflags', ['ClientIP', 'Date', 'Time', 'UserName'], result)
#           puppet_resource_should_show('logformat', 'W3C', result)
#           puppet_resource_should_show('loglocaltimerollover', 'false', result)
#           puppet_resource_should_show('logpath', 'C:\\inetpub\\logs\\NewLogFiles', result)
#           puppet_resource_should_show('logtruncatesize', '2000000', result)
#           puppet_resource_should_show('physicalpath', 'C:\\inetpub\\new', result)
#           it 'has a binding to 443' do
#             expect(result.stdout).to match(%r{'bindinginformation' => '\*:443:www.puppet.local'})
#           end

#           context 'when capitalization is changed in path parameters' do
#             describe 'applies the manifest twice' do
#               manifest = <<-HERE
#                 iis_site { '#{site_name}':
#                   ensure               => 'started',
#                   # Change capitalization to see if it break idempotency
#                   logpath              => 'C:\\ineTpub\\logs\\NewLogFiles',
#                   physicalpath         => 'C:\\ineTpub\\new',
#                 }
#               HERE

#             it_behaves_like 'an idempotent resource', manifest
#           end
#         end

#        it 'removes all' do
#           #remove_all_sites
#         end
#       end

#       context 'using preloadenabled', if: fact('kernelmajversion') != '6.1' do
#         create_path('C:\inetpub\new')
#         site_name = define_pool_name
#         describe 'applies the manifest twice' do
#           manifest = <<-HERE
#             iis_site { '#{site_name}':
#               ensure               => 'started',
#               preloadenabled       => true,
#               physicalpath         => 'C:\\inetpub\\new',
#             }
#           HERE

#           it_behaves_like 'an idempotent resource', manifest
#         end

#         context 'when puppet resource is run' do
#           result = resource('iis_site', site_name)
#           puppet_resource_should_show('ensure', 'started', result)
#           puppet_resource_should_show('preloadenabled', 'true', result)
#           puppet_resource_should_show('physicalpath', 'C:\\inetpub\\new', result)
#         end

#         it 'removes all sites' do
#           #remove_all_sites
#         end
#       end

#       context 'using non-W3C log format and logtperiod' do
#         create_path('C:\inetpub\tmp')
#         site_name = define_pool_name

#         describe 'applies the manifest twice' do
#           manifest = <<-HERE
#             iis_site { '#{site_name}':
#               ensure               => 'started',
#               applicationpool      => 'DefaultAppPool',
#               enabledprotocols     => 'https',
#               logformat            => 'NCSA',
#               loglocaltimerollover => false,
#               logpath              => 'C:\\inetpub\\logs\\NewLogFiles',
#               logperiod            => 'Daily',
#               physicalpath         => 'C:\\inetpub\\new',
#             }
#           HERE

#           it_behaves_like 'an idempotent resource', manifest
#         end

#         context 'when puppet resource is run' do
#           result = resource('iis_site', site_name)
#           puppet_resource_should_show('ensure', 'started', result)
#           puppet_resource_should_show('applicationpool', 'DefaultAppPool', result)
#           puppet_resource_should_show('enabledprotocols', 'https', result)
#           puppet_resource_should_show('logformat', 'NCSA', result)
#           puppet_resource_should_show('loglocaltimerollover', 'false', result)
#           puppet_resource_should_show('logpath', 'C:\\inetpub\\logs\\NewLogFiles', result)
#           puppet_resource_should_show('logperiod', 'Daily', result)
#           puppet_resource_should_show('physicalpath', 'C:\inetpub\new', result)
#         end

#         it 'removes all sites' do
#           #remove_all_sites
#         end
#       end
#     end

#     context 'when setting' do
#       describe 'authenticationinfo' do
#         site_name = define_pool_name
#         create_path('C:\inetpub\tmp')
#         describe 'applies the manifest twice' do
#           manifest = <<-HERE
#             iis_site { '#{site_name}':
#               ensure          => 'started',
#               physicalpath    => 'C:\\inetpub\\tmp',
#               applicationpool => 'DefaultAppPool',
#               authenticationinfo => {
#                 'basic'     => true,
#                 'anonymous' => false,
#               },
#             }
#           HERE

#           it_behaves_like 'an idempotent resource', manifest
#         end

#         it 'removes all sites' do
#           #remove_all_sites
#         end
#       end
#     end

#     context 'can change site state from' do
#       context 'stopped to started' do

#           create_path('C:\inetpub\tmp')
#           create_site(site_name, false)
#           site_name = define_pool_name

#           describe 'applies the manifest twice' do
#           manifest = <<-HERE
#           iis_site { '#{site_name}':
#             ensure          => 'started',
#             physicalpath    => 'C:\\inetpub\\tmp',
#             applicationpool => 'DefaultAppPool',
#           }
#           HERE

#         it_behaves_like 'an idempotent resource', manifest
#         end

#         context 'when puppet resource is run' do
#           before(:all) do
#             result = resource('iis_site', site_name)
#           end
#           puppet_resource_should_show('ensure', 'started')
#           puppet_resource_should_show('physicalpath', 'C:\inetpub\tmp')
#           puppet_resource_should_show('applicationpool', 'DefaultAppPool')
#         end

#        it 'removes all' do
#           #remove_all_sites
#         end
#       end

#       context 'started to stopped' do
#           create_path('C:\inetpub\tmp')
#           create_site(site_name, true)
#           site_name = define_pool_name
#           describe 'applies the manifest twice' do
#           manifest = <<-HERE
#           iis_site { '#{site_name}':
#             ensure          => 'stopped',
#             physicalpath    => 'C:\\inetpub\\tmp',
#             applicationpool => 'DefaultAppPool',
#           }
#           HERE

#         it_behaves_like 'an idempotent resource', manifest
#         end

#         context 'when puppet resource is run' do
#             result = resource('iis_site', site_name)
#           puppet_resource_should_show('ensure', 'stopped', result)
#           puppet_resource_should_show('physicalpath', 'C:\inetpub\tmp', result)
#           puppet_resource_should_show('applicationpool', 'DefaultAppPool', result)
#         end

#        it 'removes all' do
#           #remove_all_sites
#         end
#       end

#       context 'started to absent' do
#           site_name = define_pool_name
#           create_site(site_name, true)
#           describe 'applies the manifest twice' do
#           manifest = <<-HERE
#           iis_site { '#{site_name}':
#             ensure => 'absent'
#           }
#           HERE

#         it_behaves_like 'an idempotent resource', manifest
#         end

#         context 'when puppet resource is run' do
#             result = resource('iis_site', site_name)
#           puppet_resource_should_show('ensure', 'absent', result)
#         end

#        it 'removes all' do
#           #remove_all_sites
#         end
#       end
#     end

#     context 'with invalid value for' do
#       context 'logformat' do
#           create_path('C:\inetpub\wwwroot')
#           site_name = define_pool_name
#           describe 'applies the manifest twice' do
#           manifest = <<-HERE
#           iis_site { '#{site_name}':
#             ensure          => 'started',
#             physicalpath    => 'C:\\inetpub\\wwwroot',
#             applicationpool => 'DefaultAppPool',
#             logformat       => 'splurge'
#           }
#           HERE

#         it_behaves_like 'a failing manifest', manifest
#         end
#       end

#       context 'logperiod' do
#           create_path('C:\inetpub\wwwroot')
#           site_name = define_pool_name
#           describe 'applies the manifest twice' do
#           manifest = <<-HERE
#           iis_site { '#{site_name}':
#             ensure          => 'started',
#             physicalpath    => 'C:\\inetpub\\wwwroot',
#             applicationpool => 'DefaultAppPool',
#             logperiod       => 'shouldibeastring? No.'
#           }
#           HERE

#         it_behaves_like 'a failing manifest', manifest
#         end
#       end

#       it 'removes all sites' do
#         #remove_all_sites
#       end
#     end

#     context 'can changed previously set value' do
#       context 'physicalpath' do
#           site_name = define_pool_name
#           create_path('C:\inetpub\new')
#           create_site(site_name, true)
#           describe 'applies the manifest twice' do
#           manifest = <<-HERE
#           iis_site { '#{site_name}':
#             ensure          => 'started',
#             physicalpath    => 'C:\\inetpub\\new',
#             applicationpool => 'DefaultAppPool',
#           }
#           HERE

#         it_behaves_like 'an idempotent resource', manifest
#         end

#         context 'when puppet resource is run' do
#             result = resource('iis_site', site_name)
#           puppet_resource_should_show('physicalpath', 'C:\\inetpub\\new', result)
#         end

#        it 'removes all' do
#           #remove_all_sites
#         end
#       end

#       context 'applicationpool' do
#           site_name = define_pool_name
#           pool_name = define_pool_name
#           create_app_pool(pool_name)
#           create_site(site_name, true)

#           describe 'applies the manifest twice' do
#           manifest = <<-HERE
#           iis_site { '#{site_name}':
#             ensure          => 'started',
#             applicationpool => '#{pool_name}',
#           }
#           HERE

#         it_behaves_like 'an idempotent resource', manifest
#         end

#         context 'when puppet resource is run' do
#             result = resource('iis_site', site_name)
#           puppet_resource_should_show('applicationpool', pool_name)
#         end

#        it 'removes all' do
#           #remove_all_sites
#         end
#       end

#       context 'bindings' do
#           create_path('C:\inetpub\new')
#           site_name = define_pool_name
#           describe 'applies the manifest twice' do
#           setup_manifest = <<-HERE
#           iis_site { '#{site_name}':
#             ensure           => 'started',
#             physicalpath     => 'C:\\inetpub\\new',
#             enabledprotocols => 'http',
#             applicationpool  => 'DefaultAppPool',
#             bindings             => [
#               {
#                 'bindinginformation'   => '*:8080:',
#                 'protocol'             => 'http',
#               },
#               {
#                 'bindinginformation'   => '*:8084:domain.test',
#                 'protocol'             => 'http',
#               },
#             ],
#           }
#           HERE
#           execute_manifest(setup_manifest, catch_failures: true)

#           manifest = <<-HERE
#           iis_site { '#{site_name}':
#             ensure           => 'started',
#             physicalpath     => 'C:\\inetpub\\new',
#             enabledprotocols => 'http',
#             applicationpool  => 'DefaultAppPool',
#             bindings             => [
#               {
#                 'bindinginformation'   => '*:8081:',
#                 'protocol'             => 'http',
#               },
#             ],
#           }
#           HERE

#         it_behaves_like 'an idempotent resource', manifest
#         end

#         context 'when puppet resource is run' do
#             result = resource('iis_site', site_name)
#           # puppet_resource_should_show('bindings', [
#           #  {
#           #    "protocol"             => "http",
#           #    "bindinginformation"   => "*:8081:",
#           #    "sslflags"             => 0,
#           #    "certificatehash"      => "",
#           #    "certificatestorename" => "",
#           #  }
#           # ])
#         end

#        it 'removes all' do
#           #remove_all_sites
#         end
#       end

#       context 'enabledprotocols' do
#           create_path('C:\inetpub\new')
#           site_name = define_pool_name
#           describe 'applies the manifest twice' do
#           setup_manifest = <<-HERE
#           iis_site { '#{site_name}':
#             ensure           => 'started',
#             physicalpath     => 'C:\\inetpub\\new',
#             enabledprotocols => 'http',
#             applicationpool  => 'DefaultAppPool',
#           }
#           HERE
#           execute_manifest(setup_manifest, catch_failures: true)

#           manifest = <<-HERE
#           iis_site { '#{site_name}':
#             ensure           => 'started',
#             physicalpath     => 'C:\\inetpub\\new',
#             enabledprotocols => 'https',
#             applicationpool  => 'DefaultAppPool',
#           }
#           HERE
#         end

#         it_behaves_like 'an idempotent resource', manifest
#       end

#         context 'when puppet resource is run' do
#             result = resource('iis_site', site_name)
#           puppet_resource_should_show('enabledprotocols', 'https', result)
#         end

#         it 'removes all sites' do
#           #remove_all_sites
#         end
#       end

#       context 'logflags' do
#           create_path('C:\inetpub\new')
#           site_name = define_pool_name

#           describe 'applies the manifest twice' do
#           setup_manifest = <<-HERE
#           iis_site { '#{site_name}':
#             ensure           => 'started',
#             physicalpath     => 'C:\\inetpub\\new',
#             applicationpool  => 'DefaultAppPool',
#             logformat        => 'W3C',
#             logflags         => ['ClientIP', 'Date', 'HttpStatus']
#           }
#           HERE
#           execute_manifest(setup_manifest, catch_failures: true)

#           manifest = <<-HERE
#           iis_site { '#{site_name}':
#             ensure           => 'started',
#             physicalpath     => 'C:\\inetpub\\new',
#             applicationpool  => 'DefaultAppPool',
#             logformat        => 'W3C',
#             logflags         => ['ClientIP', 'Date', 'Method']
#           }
#           HERE

#         it_behaves_like 'an idempotent resource', manifest
#         end

#         context 'when puppet resource is run' do
#             result = resource('iis_site', site_name)
#           puppet_resource_should_show('logflags', ['ClientIP', 'Date', 'Method'], result)
#         end

#        it 'removes all' do
#           #remove_all_sites
#         end
#       end
#     end

#     context 'with an existing website' do
#         site_name_one = define_pool_name
#         site_name_two = define_pool_name
#         create_site(site_name_one, true)
#         create_path('C:\inetpub\basic')
#         describe 'applies the manifest twice' do
#         manifest = <<-HERE
#           iis_site { '#{site_name_two}':
#             ensure          => 'started',
#             physicalpath    => 'C:\\inetpub\\basic',
#             applicationpool => 'DefaultAppPool',
#           }
#         HERE

#       it_behaves_like 'a failing manifest', manifest
#     end

#     it 'removes all sites' do
#         #remove_all_sites
#       end
#     end

#     context 'with conflicting sites on differing ports' do
#         create_path('C:\inetpub\basic')
#         site_name = define_pool_name
#         second_site_name = define_pool_name
#         create_site(site_name, true)
#         describe 'applies the manifest twice' do
#         manifest = <<-HERE
#           iis_site { "#{second_site_name}":
#             ensure          => 'started',
#             physicalpath    => 'C:\\inetpub\\basic',
#             applicationpool => 'DefaultAppPool',
#             bindings        => [
#               {
#                 'bindinginformation' => "*:8080:#{second_site_name}",
#                 'protocol'           => 'http',
#               }
#             ],
#           }
#         HERE

#       it_behaves_like 'an idempotent resource', manifest
#         end

#       context 'when puppet resource is run' do
#         let(:first_site) {resource('iis_site', site_name)}
#         let(:second_site) {resource('iis_site', second_site_name)}

#         it 'runs the first site on port 80' do
#           expect(first_site.stdout).to match(%r{ensure(\s*)=> 'started',})
#           expect(first_site.stdout).to match(%r{\*\:80\:})
#         end

#         it 'runs the second site on port 8080' do
#           expect(second_site.stdout).to match(%r{ensure(\s*)=> 'started',})
#           expect(second_site.stdout).to match(%r{\*\:8080\:#{second_site_name}})
#         end
#       end

#       it 'removes all sites' do
#         #remove_all_sites
#       end
#     end

#     context 'with ensure set to present' do
#         create_path('C:\inetpub\basic')
#         site_name = define_pool_name
#         create_site(site_name, true)
#         describe 'applies the manifest twice' do
#         setup_manifest = <<-HERE
#         iis_site { '#{site_name}':
#             ensure           => 'stopped',
#             physicalpath     => 'C:\\inetpub\\basic',
#             applicationpool  => 'DefaultAppPool',
#             logformat        => 'W3C',
#             logflags         => ['ClientIP', 'Date', 'HttpStatus']
#         }
#         HERE

#         manifest = <<-HERE
#         iis_site { '#{site_name}':
#             ensure           => 'present',
#             physicalpath     => 'C:\\inetpub\\basic',
#             applicationpool  => 'DefaultAppPool',
#             logformat        => 'W3C',
#             logflags         => ['ClientIP', 'Date', 'HttpStatus']
#         }
#         HERE

#         execute_manifest(setup_manifest, catch_failures: true)

#       it_behaves_like 'an idempotent resource', manifest
#       end

#       context 'when puppet resource is run' do
#           result = resource('iis_site', site_name)

#         puppet_resource_should_show('ensure', 'stopped', result)
#       end
#     end
#   end

#   context 'with conflicting sites on port 80 but different host headers' do
#       create_path('C:\inetpub\basic')
#       site_name = define_pool_name
#       second_site_name = define_pool_name
#       create_site(site_name, true)
#       describe 'applies the manifest twice' do
#       manifest = <<-HERE
#         iis_site { "#{second_site_name}":
#           ensure          => 'started',
#           physicalpath    => 'C:\\inetpub\\basic',
#           applicationpool => 'DefaultAppPool',
#           bindings        => [
#             {
#               'bindinginformation' => "*:80:#{second_site_name}",
#               'protocol'           => 'http',
#             }
#           ],
#         }
#       HERE

#     it_behaves_like 'an idempotent resource', manifest
#       end

#     context 'when puppet resource is run' do
#         let(:first_site) {resource('iis_site', site_name)}
#         let(:second_site) {resource('iis_site', second_site_name)}

#       it 'runs the first site on port 80 with no host header' do
#         expect(first_site.stdout).to match(%r{ensure(\s*)=> 'started',})
#         expect(first_site.stdout).to match(%r{\*\:80\:})
#       end

#       it 'runs the second site on port 80 but a different host header' do
#         expect(second_site.stdout).to match(%r{ensure(\s*)=> 'started',})
#         expect(second_site.stdout).to match(%r{\*\:80\:#{second_site_name}})
#       end
#     end

#     it 'removes all sites' do
#       #remove_all_sites
#     end
#   end
# end
