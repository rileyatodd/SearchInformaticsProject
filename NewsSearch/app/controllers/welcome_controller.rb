require 'analyze'

class WelcomeController < ApplicationController
  def index
  	@count = count_sentences(["yo.", "dawg"])
  end
end
