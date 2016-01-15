module Preconfigure
  extend ActiveSupport::Concern

  def preconfigure
    logger.warn "CSTORE: Preconfigure called for #{master.sku}"
  end
end
