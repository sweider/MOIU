require 'matrix'
require_relative 'double_simplex_solver'
require_relative 'double_task_data'

a_matrix = Matrix.rows [
                           [1,-1,3,-2],
                           [1,-5,11,-6]
                       ]
b_vector = Matrix.column_vector [1,9]
c_vector = [1,1,-2,-3]
y_start = [3.0/2, -0.5].map(&:to_r)
j_basis = [0,1]

a_matrix = Matrix.rows [
                           [2,0,-1,1,1,4,-1],
                           [-1,0,2,1,0,3,-1],
                           [-4,1,-3,1,0,-2,1]
                       ]
c_vector = [-14,1,-9,3,1,-5,-2]
b_vector = Matrix.column_vector [6,4,-6]
y_start = [1,1,1].map(&:to_r)
j_basis = [1,3,4]
task_data = DoubleTaskData.new(a_matrix, b_vector, c_vector, y_start, j_basis)
solver = DoubleSimplexSolver.new
solution = solver.solve task_data

if (solution.nil?)
  puts solver.error_msg
else
  puts "x = {#{solution[:pseudo].map{|e| e.round(3).to_f}.join(', ')}}"
  puts "y = {#{solution[:y].map{|e| e.round(3)}.join(', ')}}"
end