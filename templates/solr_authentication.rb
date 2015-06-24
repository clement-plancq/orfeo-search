# Monkey patch a method in RSolr to inject authentication details.
# Based on this discussion:
# https://groups.google.com/forum/#!topic/blacklight-development/7xHQl2_5ZLA

class RSolr::Connection
  alias :old_setup_raw_request :setup_raw_request
  def setup_raw_request request_context
    raw_request = old_setup_raw_request request_context
    raw_request.basic_auth('admin', 'SOLR_PASSWORD');
    raw_request
  end
end
