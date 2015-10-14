class Spree::Api::TestersController < Spree::Api::BaseController
  def memory_load
    @test = Spree::Auction.all
  end
end
