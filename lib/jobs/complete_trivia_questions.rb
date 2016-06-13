module Jobs
  module CompleteTriviaQuestions
    def self.perform
      Question.pending.trivia.locked.find_each do |question|
        if question.right_answer
          question.completed = true
          question.save
        end
      end
    end
  end
end
