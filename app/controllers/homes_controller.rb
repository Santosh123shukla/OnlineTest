class HomesController < ApplicationController
  def index
    @subjects = Subject.all
  end
end
