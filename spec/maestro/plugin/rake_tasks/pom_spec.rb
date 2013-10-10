require 'spec_helper'

describe Maestro::Plugin::RakeTasks::Pom do

  let(:pom) { File.expand_path("../../../../pom.xml", __FILE__) }
  let(:subject) { Maestro::Plugin::RakeTasks::Pom.new(pom) }

  its(:artifact_id) { should eq("maestro-test-plugin") }
  its(:version) { should eq("X.Y.Z") }
  its(:description) { should eq("a description") }
  its(:url) { should eq("http://acme.com") }

  it { subject[:artifactId].should eq("maestro-test-plugin") }
  it { subject[:version].should eq("X.Y.Z") }
  it { subject[:description].should eq("a description") }
  it { subject[:url].should eq("http://acme.com") }

end
