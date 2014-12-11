class SimplexMethodIteration
  require_relative 'task_data'

  # @param [TaskData] task_data данные необходимые для итерации
  def initialize(task_data)
    @task_data = task_data
    @error_msg = nil
  end

  def iterate
    potentials = @task_data.c_basis * @task_data.b_matrix
    valuations = []
    all_gt_zero = define_valuations(potentials, valuations)
    if all_gt_zero
      {solution: @task_data.x_basis, solution?: true}
    else
      j0 = @task_data.j_not_basis[valuations.index {|e| e < 0}]
      z_vector = @task_data.b_matrix * Matrix.column_vector(@task_data.a_matrix.column(j0))
      is_any_gt_zero = !z_vector.index{|e| e > 0}.nil?
      if is_any_gt_zero
        theta = Float::INFINITY; s_indexes = []
        z_vector.each_with_index do |el, i|
          if (el > 0)
            curr_theta = @task_data.x_basis[@task_data.j_basis[i]] / el
            if curr_theta == theta
              s_indexes << i
            elsif curr_theta < theta
              theta = curr_theta
              s_indexes = [i]
            end
          end
        end
        new_x_basis = Array.new(@task_data.x_basis.size){0}
        js = @task_data.j_basis[s_indexes[0]]
        js_index = @task_data.j_basis.find_index(js)
        new_j_basis = @task_data.j_basis.clone
        new_j_basis[js_index] = j0
        new_j_basis.each_with_index { |e, i| new_x_basis[e] = @task_data.x_basis[e] - theta * z_vector[i,0] }
        new_x_basis[j0] = theta
        new_task_data = TaskData.new(@task_data.a_matrix, @task_data.b_vector, @task_data.c_vector, new_x_basis)
        {solution?: false, can_solve?: true, task_data: new_task_data}
      else
        {solution?: false, can_solve?:false, error: 'Целевая функция не ограничена сверху на множестве планов'}
      end
    end
  end

  def define_valuations(potentials, valuations)
    all_gt_zero = true
    @task_data.j_not_basis.each do |j|
      validation_j = (potentials * Matrix.column_vector(@task_data.a_matrix.column(j)))[0,0] - @task_data.c_vector[0, j]
      valuations << validation_j
      all_gt_zero = false if validation_j < 0
    end
    all_gt_zero
  end

  def calculate_potentials

  end
end