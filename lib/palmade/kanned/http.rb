module Palmade::Kanned
  unless defined?(Palmade::HttpService)
    raise HttpServiceRequired, "Palmade::HttpService gem required for this functionality"
  else
    const_set(:Http, Palmade::HttpService::Http)
  end
end
