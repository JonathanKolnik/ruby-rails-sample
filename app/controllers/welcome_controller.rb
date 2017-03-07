require 's3_handler'
class WelcomeController < ApplicationController
  def index
    @entries = Entry.where('created_at > ?', Date.current - 6.days)
  end

  def winner
    @entries = Vote.select('entry_id, count(*)').where('created_at > ?', Date.current - 6.days).group('1').order('2 desc')
  end
end
