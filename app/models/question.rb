class Question < ApplicationRecord
  belongs_to :subject
  has_many :answers, dependent: :destroy

  def correct_option_id
    correct_option = answers.find_by(correct: true)
    correct_option&.id
  end


  def correct_option
    correct_option = answers.find_by(correct: true)
    correct_option&.option
  end

  def selected_option(selected_option)
     selected_option = answers.find_by(id: selected_option)
     selected_option&.option
  end

end
