#require 'orfeo_metadata'

namespace :orfeo do
  desc "Update Solr schema to reflect Orfeo metadata definitions"

  task update: :environment do
    pwd = ENV['password']
    abort "Error: A password is required" unless pwd

    set_password pwd, 'templates/solr_authentication.rb', 'config/initializers/solr_authentication.rb'
    set_password pwd, 'templates/realm.properties', 'jetty/etc/realm.properties'

    md = OrfeoMetadata::MetadataModel.new
    md.load
    File.open('jetty/solr/blacklight-core/conf/schema.xml', 'w') do |outfile|
      File.open('templates/schema.xml') do |infile|
        infile.each do |line|
          if line =~ /<!-- ### FIELDS ### -->/
            md.output_schema outfile
          elsif line =~ /### TEXTTYPE ###/
            ttype = (ENV['stemming'] == 'true') ? 'text_fr' : 'text_ws'
            line.sub!('### TEXTTYPE ###', ttype)
            outfile.print line
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
    FileUtils::cp 'templates/stopwords.txt', 'jetty/solr/blacklight-core/conf/'
    FileUtils::cp 'templates/jetty.xml', 'jetty/etc/'
    FileUtils::cp 'templates/web.xml', 'jetty/solr-webapp/webapp/WEB-INF/'
  end
end

# Copy specified file and insert password.
def set_password(pwd, source, target)
  data = File.read source
  filtered_data = data.sub('SOLR_PASSWORD', pwd)
  File.open(target, 'w') do |f|
    f.write filtered_data
  end
end
