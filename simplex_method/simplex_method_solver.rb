class SimplexMethodSolver
  require_relative 'task_data'
  require_relative 'simplex_method_iteration'

  attr_accessor :error_msg

  def solve(task_data)
    solution = nil
    iteration = SimplexMethodIteration.new task_data
    loop do
      iteration_result = iteration.iterate
      if(iteration_result[:solution?])
        solution = iteration_result[:solution]
        break
      elsif(iteration_result[:can_solve?])
        iteration = SimplexMethodIteration.new iteration_result[:task_data]
      else
        self.error_msg = iteration_result[:error]
        break
      end
    end
    solution
  end
end