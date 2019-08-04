require 'spec_helper'
require 'puppet_x/puppetlabs/iis/powershell_manager'

describe 'iis_application provider' do
  # before :each do
  #   expect(PuppetX::IIS::PowerShellManager).not_to receive(:new)
  # end
  subject do
    resource = Puppet::Type.type(:iis_application).new(params)
    resource.provider = Puppet::Type.type(:iis_application).provider(:webadministration).new
    resource.provider
  end

  let(:facts) do
    {
      iis_version: '8.0',
      operatingsystem: 'Windows',
    }
  end

  describe 'creating from scratch' do
    context 'without physicalpath' do
      let(:params) do
        { title: 'foo\bar' }
      end

      it { expect(PuppetX::IIS::PowerShellManager).not_to receive(:new) }
      it { expect { subject.create }.to raise_error(RuntimeError, %r{physicalpath}) }
    end
    context 'with nonexistent physicalpath' do
      let(:params) do
        {
          title: 'foo\bar',
          physicalpath: 'C:\noexist',
        }
      end

      it { allow(File).to receive(:exists?).with('C:\noexist').and_return(false) }
      it { expect(PuppetX::IIS::PowerShellManager).not_to receive(:new) }
      it { expect { subject.create }.to raise_error(RuntimeError, %r{doesn't exist}) }
    end
    context 'with existent physicalpath' do
      let(:params) do
        {
          title: 'foo\bar',
          physicalpath: 'C:\exist',
          sitename: 'foo',
        }
      end

      before :each do
        allow(File).to receive(:exist?).with('C:\exist').and_return(true)
        allow(Puppet::Provider::IIS_PowerShell).to receive(:run).with(%r{New-WebApplication}).and_return(exitcode: 0)
      end
      it { subject.create }
    end
  end
  describe 'converting virtual_directory' do
    let(:params) do
      {
        title: 'foo\bar',
        virtual_directory: 'IIS:\Sites\exists\vdir',
      }
    end

    before :each do
      allow(Puppet::Provider::IIS_PowerShell).to receive(:run).with(%r{ConvertTo-WebApplication}).and_return(exitcode: 0)
    end
    it { subject.create }
  end
  describe 'updating physicalpath'
  describe 'updating sslflags'
  describe 'updating authenticationinfo'
end
