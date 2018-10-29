class BeerflowsChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'beerflows'
  end
end
