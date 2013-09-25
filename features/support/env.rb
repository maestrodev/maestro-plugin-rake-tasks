require 'aruba/cucumber'
require 'zip'

Before do
  @aruba_timeout_seconds = 20
end

Then /^the zip file "([^"]*)" should contain the following files:$/ do |zipFile, files|
  entries = []
  prep_for_fs_check do
    Zip::File.foreach(zipFile) { |zipEntry| entries << zipEntry.to_s }
  end
  expected_entries = files.raw.select{|file_row| file_row[0]}.flatten
  entries.to_set.should eq(expected_entries.to_set)
end
