#require 'orfeo_metadata'

namespace :orfeo do
  desc "Update Solr schema to reflect Orfeo metadata definitions"
  task update: :environment do
    md = OrfeoMetadata::MetadataModel.new
    md.load
    File.open('jetty/solr/blacklight-core/conf/schema.xml', 'w') do |outfile|
      File.open('templates/schema.xml') do |infile|
        infile.each do |line|
          if line =~ /<!-- ### FIELDS ### -->/
            md.output_schema outfile
          else
            outfile.print line
          end
        end
      end
    end
  end
end
