class SquareProgrammingIteration
  require 'matrix'
  require_relative 'square_task_data'

  # @param [SquareTaskData] task_data
  def do_iteration(task_data)
    potentials = -1 * task_data.c_fund * task_data.a_matrix_fund.inverse
    valuations = []
    task_data.j_not_fund.each { |j| valuations << (potentials * task_data.a_matrix.column(j) + task_data.c_x[j]) }
    if valuations.select{ |e| e < 0 }.empty?
      {solution?: true, x_vector: task_data.x_vector}
    else
      j0 = task_data.j_not_fund[valuations.find_index { |e| e < 0 }]
      h_star_matrix = form_h_star_matrix task_data
      h_j_0 = Matrix.column_vector(task_data.d_star_matrix.column(j0).to_a + task_data.a_matrix.column(j0).to_a)
      solution_array = (- h_star_matrix.inv * h_j_0).column(0).to_a
      l_star = solution_array.shift(task_data.j_star.size)
      y = solution_array
    end
  end



  # @param [SquareTaskData] task_data
  def form_h_star_matrix(task_data)
    top_part_columns = task_data.d_star_matrix.column_vectors.map(&:to_a) +
        task_data.a_star_matrix.t.column_vectors.map(&:to_a)
    bottom_part_columns = task_data.a_star_matrix.column_vectors.map(&:to_a) +
        Matrix.build(task_data.j_star.size){0}.column_vectors.map(&:to_a)
    full_rows = Matrix.columns(top_part_columns).row_vectors.map(&:to_a) +
        Matrix.columns(bottom_part_columns).row_vectors.map(&:to_a)
    Matrix.rows full_rows
  end
end