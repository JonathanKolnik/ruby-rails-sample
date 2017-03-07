require 's3_handler'
class WelcomeController < ApplicationController
  def index
    @entries = Entry.where('created_at > ?', Date.current - 7.days)
  end

  def winner
    @winner = Vote.select('entry_id, count(*)').where('created_at > ?', Date.current - 7.days).group('1').order('2 desc').first.entry
  end
end
