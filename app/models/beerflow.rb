class Beerflow < ApplicationRecord
  belongs_to :drink
  
  after_save :broadcast_save
  after_destroy :broadcast_delete

  def broadcast_save
    ActionCable.server.broadcast 'beerflows',
      status: 'saved',
      quantity: quantity.to_f,
      drink_id: drink_id
  end

  def broadcast_delete
    ActionCable.server.broadcast 'beerflows',
      status: 'deleted',
      drink_id: drink_id
  end
  
end
