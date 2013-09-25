Feature: package
  Rake package task should create a zip file

  Scenario: Packaging a plugin
    Given a file named "Rakefile" with:
    """
    require 'maestro/plugin/rake_tasks'
    Maestro::Plugin::RakeTasks::PackageTask.new
    """
    And a file named "pom.xml" with:
    """
    <?xml version="1.0"?>
    <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
      <modelVersion>4.0.0</modelVersion>
      <groupId>com.maestrodev.maestro.plugins</groupId>
      <artifactId>maestro-jenkins-plugin</artifactId>
      <version>2.3-SNAPSHOT</version>
    </project>
    """
    And a file named "manifest.template.json" with:
    """
    {
      "tasks": [
        {
          "name": "jenkins plugin",
          "description": "Run A Set Of Work Steps In Jenkins",
          "license": "Apache 2.0",
          "author": "Kelly Plummer",
          "version": "updated at build time",
          "class": "MaestroDev::Plugin::JenkinsWorker",
          "type": "ruby",
          "dependencies": [],
          "task": {
            "command": "/jenkinsplugin/build",
            "inputs": {},
            "outputs": {},
            "icon": "jenkins.png",
            "tool_name": "Build"
          }
        },
        {
          "name": "jenkins sync",
          "description": "Get the data from the latest build for a particular job",
          "license": "Apache 2.0",
          "author": "Etienne Pelletier",
          "version": "updated at build time",
          "class": "MaestroDev::Plugin::JenkinsWorker",
          "type": "ruby",
          "dependencies": [],
          "task": {
            "command": "/jenkinsplugin/get_build_data",
            "inputs": {},
            "outputs": {},
            "icon": "jenkins.png",
            "tool_name": "Build"
          }
        }
      ]
    }
    """
    And an empty file named "src/test.rb"
    And an empty file named "vendor/cache/andand-1.3.3.gem"
    And an empty file named "README.md"
    And an empty file named "LICENSE"
    When I run `rake package`
    Then the exit status should be 0
    And a file named "maestro-jenkins-plugin-2.3-SNAPSHOT.zip" should exist
    And I run `unzip -t maestro-jenkins-plugin-2.3-SNAPSHOT.zip`
    Then the zip file "maestro-jenkins-plugin-2.3-SNAPSHOT.zip" should contain the following files:
        | manifest.json |
        | LICENSE |
        | README.md |
        | src/test.rb |
        | vendor/cache/andand-1.3.3.gem |
