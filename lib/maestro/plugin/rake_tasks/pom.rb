require 'nokogiri'

module Maestro
  module Plugin
    module RakeTasks
      class Pom

        def initialize(pom_path = "pom.xml")
          pom = File.open(pom_path)
          @doc = Nokogiri::XML(pom.read)
          pom.close
        end

        def [](id)
          xpath(@doc, id)
        end

        def artifact_id
          @artifact_id ||= self[:artifactId]
        end

        def version
          @version ||= self[:version]
        end

        def description
          @description ||= self[:description]
        end

        def url
          @url ||= self[:url]
        end

        private

        def xpath(doc, attribute)
          item = doc.at_xpath("/xmlns:project/xmlns:#{attribute}")
          item.nil? ? nil : item.text
        end
      end
    end
  end
end
