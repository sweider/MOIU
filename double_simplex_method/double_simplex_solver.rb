class DoubleSimplexSolver
  require_relative 'double_task_data'
  require_relative 'double_simplex_iteration'

  attr_reader :error_msg
  def initialize
    @error_msg = nil
  end

  # @param [DoubleTaskData] task_data
  def solve(task_data)
    solution = {pseudo: nil, y: nil }
    iteration = DoubleSimplexIteration.new task_data
    loop do
      iteration_result = iteration.iterate
      if(iteration_result[:solution?])
        solution[:pseudo] = iteration_result[:pseudo_plan]
        solution[:y] = iteration_result[:y_plan]
        break
      elsif(iteration_result[:can_solve?])
        iteration = DoubleSimplexIteration.new iteration_result[:task_data]
      else
        @error_msg = iteration_result[:error]
        solution = nil
        break
      end
    end
    solution
  end
end