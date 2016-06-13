require 'jobs/process_game_results_batch'

module Jobs
  class ProcessGameResults < Struct.new(:game_id, :completed)
    def perform
      game = Game.find(game_id)
      game.pickem_entries.find_in_batches(:batch_size => 300) do |batch|
        Delayed::Job.enqueue ProcessGameResultsBatch.new(game_id, batch.collect(&:id), completed)
      end
    end

    def error(job, exception)
      Airbrake.notify(exception)
    end
  end
end
