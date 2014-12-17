class Solver
  require_relative 'square_base_task_data'
  require_relative 'square_programming_iteration'
  attr_reader :error


  # @param [SquareBaseTaskData] task_data
  # @return [Vector]
  def solve(task_data)
    result = nil; iteration_data = task_data
    iteration = SquareProgrammingIteration.new
    iterations = 0
    loop do
      iterations += 1
      iteration_result =  iteration.do_iteration(iteration_data)
      if(iteration_result[:solution?])
        result = iteration_result[:x_vector]
        break
      elsif iteration_result[:solveable?]
        iteration_data = iteration_result[:data]
      else
        result = nil
        @error = 'Целевая фукнция не ограничена снизу на множестве планов!'
        break
      end
    end
    puts "Iterations: #{iterations}"
    result
  end
end