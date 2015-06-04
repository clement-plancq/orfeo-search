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

    File.open('jetty/solr/blacklight-core/conf/solrconfig.xml', 'w') do |outfile|
      File.open('templates/solrconfig.xml') do |infile|
        infile.each do |line|
          if line =~ /<!-- ### fl ### -->/
            md.fields.each do |field|
              outfile.puts "         #{field.name}," if field.show_in_concordancer? || field.show_in_snippet_view?
            end
          elsif line =~ /<!-- ### facets ### -->/
            md.fields.each do |field|
              outfile.puts "       <str name=\"facet.field\">#{field.name}</str>" if field.facet?
            end
          else
            outfile.print line
          end
        end
      end
    end

    # Also copy over any of our files that differ from the
    # jettywrapped Solr's defaults.
    FileUtils::cp 'templates/stopwords.txt', 'jetty/solr/blacklight-core/conf/stopwords.txt'
  end
end
