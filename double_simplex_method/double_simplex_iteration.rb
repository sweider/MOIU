class DoubleSimplexIteration
  require_relative 'double_task_data'
  require_relative '../utils/ek_vector_factory'
  # @param [DoubleTaskData] task_data
  def initialize(task_data)
    @task_data = task_data
  end

  def iterate
    pseudo_plan = (@task_data.b_matrix * @task_data.b_vector).column(0).to_a
    basis_pseudo =  pseudo_plan # pseudo_plan.select { |e| @task_data.j_basis.include?(pseudo_plan.index(e)) }
    if basis_pseudo.select { |e| e < 0 }.empty?
      #  здесь завернуть псевдо полный и У
      result_pseudo = []
      @task_data.j_full.each { |e| result_pseudo << (@task_data.j_basis.include?(e) ? basis_pseudo[@task_data.j_basis.index(e)]: 0)}
      {solution?: true, pseudo_plan: result_pseudo, y_plan:@task_data.y_plan}
    else
      s = basis_pseudo.index { |e| e < 0 }
      js = @task_data.j_basis[s]
      delta_y = EKVectorFactory.getEKRowVector(@task_data.b_matrix.row_size, s) * @task_data.b_matrix
      u = []
      @task_data.j_not_basis.each { |e| u << (delta_y * Matrix.column_vector(@task_data.a_matrix.column(e)))[0,0] }
      if u.select { |e| e < 0}.empty?
        {solution?: false, can_solve?: false, error: 'Cannot solve: source_task -- incompatibility getted, double -- not limited from bottom'}
      else
        theta = Float::INFINITY; j0 = -1
         u.each_with_index do |uj, i|
           if uj < 0
             index = @task_data.j_not_basis[i]
             curr_theta = (@task_data.c_vector[index] - (Matrix.row_vector(@task_data.a_matrix.column(index)) * Matrix.column_vector(@task_data.y_plan))[0,0]) / uj
             if curr_theta < theta
               theta = curr_theta
               j0 = index
             end
           end
         end
        variable = (theta * delta_y).row(0).to_a
        y_new = @task_data.y_plan.zip(variable).map { |e,x| e + x }
        js_index = @task_data.j_basis.find_index(js)
        j_basis_new = @task_data.j_basis.clone
        j_basis_new[js_index] = j0
        @task_data.reinitialize(y_new, j_basis_new)
        {solution?: false, can_solve?: true, task_data: @task_data}
      end
    end
  end
end