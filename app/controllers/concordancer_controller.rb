# -*- encoding : utf-8 -*-
#
class ConcordancerController < CatalogController
  before_filter :startup

  include Blacklight::Catalog

  add_nav_action :lang_switcher, partial: '/lang_switcher'

  def startup
    blacklight_config.configure do |config|
      ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
      config.default_solr_params = {
        qt: 'search',
        rows: 50,
        fl: '*',
        # This syntax is OK in Ruby 2.2 but not in earlier versions:
        #'hl.fl': 'text',
        'hl.fl'.to_sym => 'text',
        'hl.simple.pre'.to_sym => '<mark>',
        'hl.simple.post'.to_sym => '</mark>',
        'hl.snippets'.to_sym => 999,
        'hl.fragsize'.to_sym => 0,
        hl: true
      }

      # solr path which will be added to solr base url before the other solr params.
      #config.solr_path = 'select'

      # items to show per page, each number in the array represent another option to choose from.
      #config.per_page = [10,20,50,100]

      ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or
      ## parameters included in the Blacklight-jetty document requestHandler.
      #
      #config.default_document_solr_params = {
      #  :qt => 'document',
      #  ## These are hard-coded in the blacklight 'document' requestHandler
      #  # :fl => '*',
      #  # :rows => 1
      #  # :q => '{!raw f=id v=$id}'
      #}

      # solr field configuration for search results/index views
      config.index.title_field = 'nomFichier'
      config.index.display_type_field = 'format'

      # solr field configuration for document/show views
      #config.show.title_field = 'title_display'
      #config.show.display_type_field = 'format'

      #    config.add_search_field 'text', :label => 'Texte'
      config.add_search_field 'text'

      # The metadata model defines which fields are facets, search fields etc.
      #   The ordering of the field names is the order of the display
      md = OrfeoMetadata::MetadataModel.new
      md.load
      md.fields.each do |mdfield|
        para = {label: mdfield.to_s}
        if mdfield.facet?
          config.add_facet_field mdfield.name, para
        end
        if mdfield.show_in_concordancer?
          config.add_index_field mdfield.name, para
        end
        if mdfield.name == 'nomFichier' || mdfield.name == 'url'
          para.merge!({helper_method: :sample_link_helper})
        end
        config.add_show_field mdfield.name, para
      end

      config.add_show_field 'text', label: 'Texte'
      config.add_index_field 'text', label: 'Texte', highlight: true

      # Have BL send all facet field names to Solr, which has been the default
      # previously. Simply remove these lines if you'd rather use Solr request
      # handler defaults, or have no facets.
      config.add_facet_fields_to_solr_request!

      # "sort results by" select (pulldown)
      # label in pulldown is followed by the name of the SOLR field to sort by and
      # whether the sort is ascending or descending (it must be asc or desc
      # except in the relevancy case).
      # (TO BE ADDED)

      # If there are more than this many search results, no spelling ("did you
      # mean") suggestion is offered.
      config.spell_max = 5
    end
  end
end
