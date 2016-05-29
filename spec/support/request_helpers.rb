module Requests; end
module Requests::JsonHelpers
  def json
    @json ||= JSON.parse(response.body)
  end
end
