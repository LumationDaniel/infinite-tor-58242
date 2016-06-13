require 'jobs/process_question_results_batch'

module Jobs
  class ProcessQuestionResults < Struct.new(:question_id, :completed)
    def perform
      question = Question.find(question_id)
      question.user_answers.find_in_batches(:batch_size => 300) do |batch|
        Delayed::Job.enqueue ProcessQuestionResultsBatch.new(question_id, batch.collect(&:id), completed)
      end
    end

    def error(job, exception)
      Airbrake.notify(exception)
    end
  end
end
