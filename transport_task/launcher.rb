require 'matrix'
def define_x_start_and_u_basis(a_array, b_array, rows, cols, u_basis, x_arrays)
  a_left = a_array.clone
  b_left = b_array.clone

  skipping_cols = []
  (0..rows - 1).each do |i|
    (0..cols - 1).each do |j|
      next if skipping_cols.include?(j)
      u_basis << {i: i, j: j}
      if a_left[i] <= b_left[j]
        x_arrays[i][j] = a_left[i]
        # skipping_rows << i
        b_left[j] -= a_left[i]
        break
      else
        x_arrays[i][j] = b_left[j]
        skipping_cols << j
        a_left[i] -= b_left[j]
      end
    end
  end
end


def define_potentials(c_matrix, u_basis, u_potentials, v_potentials)
  checked = []
  to_calculate = u_basis.select{ |u| u[:i] == 0 }
  to_calculate.each do |e|
    v_potentials[e[:j]] = c_matrix[e[:i], e[:j]] - u_potentials[e[:i]]
    checked << e
  end


  changed = false
  loop do
    changed = false
    not_checked = u_basis - checked
    checked.each do |e|
      in_column = not_checked.select {|n_e| n_e[:j] == e[:j]}
      in_column.each do |i_c|
        u_potentials[i_c[:i]] = c_matrix[i_c[:i], i_c[:j]] - v_potentials[i_c[:j]]
        checked << i_c
        not_checked.delete(i_c)
        changed = true
      end
    end

    checked.each do |e|
      in_row = not_checked.select {|n_e| n_e[:i] == e[:i]}
      in_row.each do |i_r|
        v_potentials[i_r[:j]] = c_matrix[i_r[:i], i_r[:j]] - u_potentials[i_r[:i]]
        checked << i_r
        not_checked.delete(i_r)
        changed = true
      end
    end
    break unless changed#not_checked.empty?
  end
end

def define_valuations_and_check_optimal(c_matrix, rows, cols, u_potentials, v_potentials, valuations)
  is_optimal = true
  (0..rows - 1).each do |i|
    break unless is_optimal
    (0..cols - 1).each do |j|
      break unless is_optimal
      valuations[i][j] = u_potentials[i] + v_potentials[j] - c_matrix[i, j]
      is_optimal = valuations[i][j] <= 0
      return {optimal?: false, ij:{i:i, j: j}} unless is_optimal
    end
  end
  {optimal?: true}
end

# @param [Hash] u
def delete_singles!(u,rows, cols)
  loop do
    smth_was_deleted = false
    (0..cols - 1).each do |j|
      elements = u.select{ |e| e[:j] == j }
      if elements.size == 1
        u.delete elements[0]
        smth_was_deleted = true
      end
    end
    (0..rows - 1).each do |i|
      elements = u.select{ |e| e[:i] == i }
      if elements.size == 1
        u.delete elements[0]
        smth_was_deleted = true
      end
    end
    break unless smth_was_deleted
  end
end

def insert_to_basis(u_basis, ij)
  u_basis.each_with_index do |u, ind|
    next if u[:i] < ij[:i]
    next if u[:i] == ij[:i] && u[:j] <= ij[:j]
    u_basis.insert(ind, ij)
    break
  end
end

def calculate_sum(c_matrix, cols, rows, x_arrays)
  sum = 0
  (0..rows - 1).each do |i|
    (0..cols - 1).each do |j|
      sum += c_matrix[i, j] * x_arrays[i][j]
    end
  end
  sum
end

def define_stars_and_theta0(u_basis, x_arrays)
  theta_0 = Float::INFINITY; ij_star = {}
  u_basis.each do |u|
    if x_arrays[u[:i]][u[:j]] < theta_0
      theta_0 = x_arrays[u[:i]][u[:j]]
      ij_star = {i: u[:i], j: u[:i]}
    end
  end
  return ij_star, theta_0
end


a_array = [2,2,2]
b_array = [2,2,2]
c_matrix = Matrix.rows [
                           [1,2,3],
                           [4,5,6],
                           [7,8,9]
                       ]
a_array = [40,35,10,25]
b_array = [5,15,10,10,20,30,20]
c_matrix = Matrix.rows [
                           [10,15,3,10,8,1,-15],
                           [7,8,4,1,6,-6,7],
                           [4,-3,6,9,12,6,13],
                           [-10,5,8,-4,2,5,11]
                       ]
a_array = Array.new(6){4}
b_array = Array.new(6){4}
c_matrix = Matrix.rows [
                           [12,11,6,4,-7,100],
                           [8,8,12,4,100,3],
                           [13,1,6,100,-4,5],
                           [4,7,100,50,4,6],
                           [2,100,4,5,20,7],
                           [100,-1,2,3,8,10]
                           # [2,6,9,11,7,-20],
                           # [7,10,5,3,8,5],
                           # [1,8,-6,18,0,4],
                           # [-30,1,2,14,5,8],
                           # [19,-8,6,10,5,7],
                           # [-10,3,7,9,4,8]
                       ]

a_array = [20,20,15,5]
b_array = [10,5,4,10,11,10,10]
c_matrix = Matrix.rows [
                           [2,1,2,3,4,8,-100],
                           [4,20,2,4,4,5,-2],
                           [-1,-3,1,1,10,1,-1],
                           [-10,-5,3,5,3,20,30]
                       ]


rows = a_array.size; cols = b_array.size
x_arrays = Array.new(rows){ Array.new(cols) {0} }

if a_array.inject(:+) != b_array.inject(:+)
  puts 'План перевозок не существует. Сумма(а) не равна Сумма(b)'
  exit(1)
end

u_basis = []
define_x_start_and_u_basis(a_array, b_array, rows, cols, u_basis, x_arrays)
prev_size = u_basis.size
iteration = 0
loop do
  sum = calculate_sum(c_matrix, cols, rows, x_arrays)
  puts "Current sum = #{sum}"
  u_potentials = Array.new(rows) { |i| 0 if i == 0}; v_potentials = Array.new(cols)
  break if u_basis.size < prev_size
  define_potentials(c_matrix, u_basis, u_potentials, v_potentials)

  valuations = Array.new(rows) { Array.new(cols) }
  calculation_result = define_valuations_and_check_optimal(c_matrix, rows, cols, u_potentials, v_potentials, valuations)
  break if calculation_result[:optimal?]

  u_basis_clone= []
  u_basis.each {|e| u_basis_clone << e}
  insert_to_basis(u_basis_clone, calculation_result[:ij])
  delete_singles!(u_basis_clone, rows,cols)

  # ij_star, theta_0 = define_stars_and_theta0(u_basis, x_arrays)
  # insert_to_basis(u_basis,calculation_result[:ij])
  loop_array = []
  loop_array[0] = calculation_result[:ij]
  u_basis_clone.delete(calculation_result[:ij])

  is_previous_by_rows = false
  (1..u_basis_clone.size).each do |index|
    if (!is_previous_by_rows)
      i_prev = loop_array[index - 1][:i]
      curr_step = u_basis_clone.find { |e| e[:i] == i_prev }
      loop_array << curr_step
      is_previous_by_rows = true
      u_basis_clone.delete(curr_step)
    else
      j_prev = loop_array[index - 1][:j]
      curr_step = u_basis_clone.find { |e| e[:j] == j_prev }
      loop_array << curr_step
      is_previous_by_rows = false
      u_basis_clone.delete(curr_step)
    end
  end
  loop_odd_indexed_elms = loop_array.select{ |e| loop_array.index(e).odd? }
  theta_0 = Float::INFINITY; ij_star = {}
  u_basis.each do |u|
    if loop_odd_indexed_elms.include? u
      x = x_arrays[u[:i]][u[:j]]
      if x < theta_0
        theta_0 = x
        ij_star = u
      end
    end
  end
  loop_array.each_with_index do |e, i|
    x_arrays[e[:i]][e[:j]] += i.odd? ? -theta_0 : theta_0
  end
  u_basis.delete ij_star
  insert_to_basis(u_basis,calculation_result[:ij])
  puts 'iteration finish'
  iteration += 1
end

x_arrays.each {|e| puts "\t #{e}"}
puts "Iteration: #{iteration}"
