class SquareProgrammingIteration
  require 'matrix'
  require_relative 'square_base_task_data'
  require_relative 'square_extended_task_data'
  require_relative '../utils/ek_vector_factory'

  # @param [SquareBaseTaskData] data
  def do_iteration(data)
    if(data.class == SquareBaseTaskData)
      do_full_iteration(data)
    else
      do_from_step_4(data.base_data, data.j0,data.valuation_j0)
    end
  end

  protected
  # @param [SquareBaseTaskData] task_data
  def do_full_iteration(task_data)
    potentials = -1 * (task_data.c_fund.t * task_data.a_matrix_fund.inverse)
    valuations = []
    task_data.j_not_star.each { |j| valuations << ((potentials * task_data.a_matrix.column(j))[0] + task_data.c_x[j,0]) }
    if valuations.select { |e| e < 0 }.empty?
      {solution?: true, x_vector: task_data.x_vector}
    else
      puts "J_not_fund: #{task_data.j_not_star}"
      puts "Valuations for j_not_fund: #{valuations.map{|e| e.to_f.round(3)}}"
      valuation_j0_index = valuations.find_index { |e| e < 0 }
      j0 = task_data.j_not_star[valuation_j0_index]
      puts "j0: #{j0}"
      do_from_step_4(task_data, j0, valuations[valuation_j0_index])
    end
  end

  # @param [SquareBaseTaskData] base_data
  def do_from_step_4(base_data, j0,valuation_j0)
    temp_result = perform_calculations(base_data, j0, valuation_j0)
    if temp_result[:solveable?]
      x = temp_result[:x_new]
      puts "Current x is #{x.column(0).to_a.map{|e| e.to_f.round(3)}}"
      puts "Function is #{(base_data.c.t * x)[0,0] + 0.5 * (x.t * base_data.d_matrix * x)[0,0]}"
      puts "\n"
      define_iteration_result(j0, base_data, temp_result, valuation_j0)
    else
      {solution?: false, solveable?: false}
    end
  end

  # @param [SquareBaseTaskData] base_data
  def perform_calculations(base_data, j0, valuation_j0)
    puts "j0: #{j0}, valuation_j0: #{valuation_j0.to_f.round(3)}"
    h_star_matrix = form_h_star_matrix base_data
    d_star_j0_array = base_data.d_star_rows_matrix.column(j0).to_a
    a_matrix_j0_array = base_data.a_matrix.column(j0).to_a
    h_j_0 = Matrix.column_vector(d_star_j0_array + a_matrix_j0_array)
    solution_array = (-1 * ( h_star_matrix.inv * h_j_0)).column(0).to_a
    l_star = solution_array.shift(base_data.j_star.size)
    y = solution_array
    sigma = (Matrix.row_vector(d_star_j0_array) * Matrix.column_vector(l_star))[0,0] +
        (Matrix.row_vector(a_matrix_j0_array) * Matrix.column_vector(y))[0,0] + base_data.d_matrix[j0,j0]
    theta_j0 = sigma.abs < 0.000000001 ? Float::INFINITY : (valuation_j0 / sigma).abs
    theta_arr = []
    l_star.zip(base_data.x_star_array).map {|l_j, x_j|
      theta_arr << (l_j < 0 ? (-1 * (x_j/l_j)) : Float::INFINITY)
    }
    theta_arr << theta_j0
    theta_0 = theta_arr.inject {|min, el| el < min ? el : min}
    if theta_0 == Float::INFINITY
      {solveable?: false}
    else
      j_star = theta_0 == theta_j0 ? j0 : base_data.j_star[theta_arr.find_index(theta_0)]
      j_not_fund_temp = base_data.j_not_star.clone.delete_if{|e| e == j0}
      x_new = Array.new(base_data.x_vector.row_size) {0}
      # j_not_fund_temp.each {|j| x_new[j] = 0}
      base_data.j_star.each_with_index { |j_star, i| x_new[j_star] = base_data.x_vector[j_star,0] + theta_0 * l_star[i] }
      x_new[j0] = base_data.x_vector[j0,0] + theta_0
      { solveable?: true, j_star: j_star, theta_0: theta_0, sigma: sigma, x_new: Matrix.column_vector(x_new) }
    end
  end

  def define_iteration_result(j0, task_data, temp_result, valuation_j0)
    iteration_result = {}
    j_star_wo_fund = task_data.j_star.reject { |e| task_data.j_fund.include?(e) }
    if temp_result[:j_star] == j0
      iteration_result = a_case(task_data, temp_result,j0)
    elsif j_star_wo_fund.include?(temp_result[:j_star])
      iteration_result = b_case(task_data, temp_result, j0, valuation_j0)
    elsif task_data.j_fund.include?(temp_result[:j_star])
      iteration_result = define_between_c_and_d_cases(j0, j_star_wo_fund, task_data, temp_result, valuation_j0)
    end
    iteration_result
  end

  # @return [Hash]
  def define_between_c_and_d_cases(j0, j_star_wo_fund, task_data, temp_result, valuation_j0)
    calculations = []; s = task_data.j_fund.find_index(temp_result[:j_star])
    e_s = EKVectorFactory.getEKRowVector(task_data.a_matrix.row_size, s)
    a_fund_inverted = task_data.a_matrix_fund.inv
    j_star_wo_fund.each do |j|
      calculations << (e_s * a_fund_inverted * Matrix.column_vector(task_data.a_matrix.column(j)))[0, 0]
    end
    j_plus_index = calculations.find_index { |e| e != 0 }
    j_plus = j_plus_index.nil? ? nil :  j_star_wo_fund[j_plus_index]
    if (j_plus.nil?)
      iteration_result = g_case(task_data, temp_result, j0)
    else
      iteration_result = v_case(task_data, temp_result, j0, j_plus, valuation_j0)
    end
    iteration_result
  end

  # @param [SquareBaseTaskData] task_data
  # @param [Hash] temp_result
  def a_case(task_data, temp_result, j0)
    task_data.j_star.push(j0).sort!
    task_data.reinitialize(temp_result[:x_new], task_data.j_fund, task_data.j_star)
    { solution?: false, solveable?: true, next_short?: false, data: task_data }
  end

  # @param [SquareBaseTaskData] task_data
  # @param [Hash] temp_result
  def b_case(task_data, temp_result,j0, valuation_j0_old)
    valuation_j0 = valuation_j0_old + temp_result[:theta_0] * temp_result[:sigma]
    j_star_new = task_data.j_star.reject { |e| e == temp_result[:j_star] }
    task_data.reinitialize(temp_result[:x_new], task_data.j_fund, j_star_new)
    data = SquareExtendedTaskData.new(j0, valuation_j0, task_data)
    { solution?: false, solveable?: true, next_short?: true, data: data }
  end

  # @param [SquareBaseTaskData] task_data
  # @param [Hash] temp_result
  def g_case(task_data, temp_result, j0)
    task_data.j_fund.delete_if{|e| e == temp_result[:j_star]}.push(j0).sort!
    task_data.j_star.delete_if{|e| e == temp_result[:j_star]}.push(j0).sort!
    task_data.reinitialize(temp_result[:x_new], task_data.j_fund, task_data.j_star)
    { solution?: false, solveable?: true, next_short?: false, data: task_data }
  end

  # @param [SquareBaseTaskData] task_data
  # @param [Hash] temp_result
  # @return [Hash]
  def v_case(task_data, temp_result,j0,j_plus, valuation_j0_old)
    valuation_j0 = valuation_j0_old + temp_result[:theta_0] * temp_result[:sigma]
    task_data.j_fund.delete_if{|j| j == temp_result[:j_star]}.push(j_plus).sort!
    task_data.j_star.delete(temp_result[:j_star])
    task_data.reinitialize(temp_result[:x_new], task_data.j_fund, task_data.j_star)
    data = SquareExtendedTaskData.new(j0, valuation_j0, task_data)
    { solution?: false, solveable?: true, next_short?: true, data: data }
  end


  # @param [SquareBaseTaskData] data
  # @return [Matrix]
  def form_h_star_matrix(data)
    a_star_t = data.a_star_matrix.t
    top_part_columns = data.d_star_matrix.column_vectors.map(&:to_a) +
        a_star_t.column_vectors.map(&:to_a)
    bottom_part_columns = data.a_star_matrix.column_vectors.map(&:to_a) +
        Matrix.build(data.a_star_matrix.row_size, a_star_t.column_size){0}.column_vectors.map(&:to_a)
    full_rows = Matrix.columns(top_part_columns).row_vectors.map(&:to_a) +
        Matrix.columns(bottom_part_columns).row_vectors.map(&:to_a)
    Matrix.rows full_rows
  end
end