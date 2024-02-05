# app/controllers/questions_controller.rb
class QuestionsController < ApplicationController
  def new
   
  end


  def create
    # Assuming you want to handle the uploaded file here
    parse_and_save_excel(params[:file])
    flash[:notice] = 'File uploaded successfully!' # Add a flash message if needed
    redirect_to root_path # Redirect to the desired path after the upload
  end




   def take_test
    @subject = Subject.find(params[:subject_id])
    @questions = @subject.questions.order("RANDOM()").limit(5)
   end	



  def submit_test
    answers = params[:answers]
    @score, @questions_with_answers = evaluate_test(answers)
    render 'test_result'
  end



  def download_template
    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: 'Questions') do |sheet|
      sheet.add_row(['subject_name', 'question_text', 'option1_text', 'option1_correct', 'option2_text', 'option2_correct', 'option3_text', 'option3_correct', 'option4_text', 'option4_correct'])

      # Add sample data or leave cells blank for user to fill in
      sheet.add_row(['Math', 'What is 2 + 2?', 'Four', 1, 'Five', 0, 'Six', 0, 'Seven', 0])
    end

    send_data package.to_stream.read, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', filename: 'questions_template.xlsx'
  end

  



  

  private

   def parse_and_save_excel(file)

    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)

	    (2..spreadsheet.last_row).each do |i|
	      row = Hash[[header, spreadsheet.row(i)].transpose]

	      subject = Subject.find_or_create_by(name: row['subject_name'])
	      question = subject.questions.create(text: row['question_text'])

	      4.times do |j|
	        correct = row["option#{j + 1}_correct"].to_i == 1
	        question.answers.create(option: row["option#{j + 1}_text"], correct: correct)
	      end
	    end
    end


    def evaluate_test(answers)
   	    @correct_answers = 0
	    @questions_with_answers = []

	    answers.each do |question_id, selected_option_id|
	      question = Question.find(question_id)
	      correct_option_id = question.correct_option_id

	      @correct_answers += 1 if correct_option_id.to_s == selected_option_id.to_s

	      @questions_with_answers << {
	        question: question.text,
	        selected_option: question.selected_option(selected_option_id),
	        correct_option: question.correct_option
	      }
	    end

	    [@correct_answers, @questions_with_answers]
	  end



  
end
