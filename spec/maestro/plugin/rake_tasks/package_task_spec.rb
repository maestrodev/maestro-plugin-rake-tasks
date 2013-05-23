require 'spec_helper'

describe Maestro::Plugin::RakeTasks::PackageTask do

  before(:each) do
    @task = Maestro::Plugin::RakeTasks::PackageTask.new
    @task.pom_path = File.dirname(__FILE__) + '/../../../pom.xml'
    @task.manifest_template_path = File.dirname(__FILE__) + '/../../../manifest.template.json'
  end

  it 'should read version number and plugin name from a pom.xml' do

    @task.stub(:git_version!)
    @task.stub(:update_manifest)
    @task.stub(:create_zip_file)
    @task.run_task true
    @task.version.should == 'X.Y.Z'
    @task.plugin_name.should == 'maestro-test-plugin'

  end

  it 'should override the pom values' do
    @task.stub(:git_version!)
    @task.stub(:update_manifest)
    @task.stub(:create_zip_file)
    @task.version='1.2.3'
    @task.plugin_name='test'
    @task.run_task true
    @task.version.should == '1.2.3'
    @task.plugin_name.should == 'test'
  end

  it 'should fail if the version is not read from pom and not set' do
    @task.stub(:git_version!)
    @task.stub(:update_manifest)
    @task.stub(:create_zip_file)
    @task.plugin_name='test'
    @task.use_pom=false

    expect {
      @task.run_task true
    }.to raise_error( SystemExit )

  end


  it 'should fail if the plugin name is not read from pom and not set' do
    @task.stub(:git_version!)
    @task.stub(:update_manifest)
    @task.stub(:create_zip_file)
    @task.version='1.2.3'
    @task.use_pom=false

    expect {
      @task.run_task true
    }.to raise_error( SystemExit )

  end

  it 'should create an updated manifest file for multi-tasks manifests' do
    @task.stub(:git_version!)
    @task.stub(:create_zip_file)
    @task.run_task true

    manifest_path = File.dirname(__FILE__) + '/../../../../manifest.json'
    File.exists?(manifest_path).should be_true
    manifest = JSON.parse(IO.read(manifest_path))
    manifest.first['version'].should start_with 'X.Y.Z'

  end

  it 'should create an updated manifest file for single-task manifests' do
    @task.stub(:git_version!)
    @task.stub(:create_zip_file)
    @task.manifest_template_path=File.dirname(__FILE__) + '/../../../manifest-single-task.template.json'
    @task.run_task true

    manifest_path = File.dirname(__FILE__) + '/../../../../manifest.json'
    File.exists?(manifest_path).should be_true
    manifest = JSON.parse(IO.read(manifest_path))
    manifest['version'].should start_with 'X.Y.Z'

  end

  it 'should name the zip file based on the plugin_name and version' do
    @task.stub(:git_version!)
    @task.stub(:update_manifest)
    @task.should_receive(:create_zip_file).with('maestro-test-plugin-X.Y.Z.zip')
    @task.run_task true
  end

  it 'should add default directories to the zip file' do
    @task.stub(:git_version!)
    @task.stub(:update_manifest)
    @task.stub(:add_file)
    @task.should_receive(:add_dir).with(anything(), 'src')
    @task.should_receive(:add_dir).with(anything(), 'vendor')
    @task.should_receive(:add_dir).with(anything(), 'images')
    @task.run_task true
  end

  it 'should add default files to the zip file' do
    @task.stub(:git_version!)
    @task.stub(:update_manifest)
    @task.stub(:add_dir)
    @task.should_receive(:add_file).with(anything(), 'manifest.json')
    @task.should_receive(:add_file).with(anything(), 'LICENSE')
    @task.should_receive(:add_file).with(anything(), 'README.md')
    @task.run_task true
  end


end