require 'matrix'
require_relative 'square_base_task_data'
require_relative 'solver'

a_matrix = Matrix.rows [
                           [1,0,2,1],
                           [0,1,-1,2]
                       ]
d_matrix = Matrix.rows [
                           [2,1,1,0],
                           [1,1,0,0],
                           [1,0,1,0],
                           [0,0,0,0]
                       ]
x_vector = Matrix.column_vector [2,3,0,0]
c_vector = Matrix.column_vector [-8,-6,-4,-6]
b_array = [2,3]
j_fund = [0,1]
j_star = [0,1]

a_matrix = Matrix.rows [
                         [1,2,0,1,0,4,-1,-3],
                         [1,3,0,0,1,-1,-1,2],
                         [1,4,1,0,0,2,2,0]
                       ]
b_array = [4,5,10]
c_vector = Matrix.column_vector [-20,-62,14,0,-42,-32,22,-14]
d_matrix = Matrix.rows [
                           [12,22,-2,0,12,-14,-6,-4],
                           [22,82,-2,0,14,-48,0,-6],
                           [-2,-2,2,0,-6,-8,4,-2],
                           [0,0,0,0,0,0,0,0],
                           [12,14,-6,0,22,12,-14,2],
                           [-14,-48,-8,0,12,84,-14,20],
                           [-6,0,4,0,-14,-14,10,-2],
                           [-4,-6,-2,0,2,20,-2,6]
                       ]
x_vector = Matrix.column_vector [0,0,10,4,5,0,0,0]
j_fund = [2,3,4]
j_star = [2,3,4]


a_matrix = Matrix.rows [
                           [1,1,1,0,-2,2,-6,3,4],
                           [3,0,1,0,3,4,-8,1,-3],
                           [0,0,1,1,1,5,-7,-1,2]
                       ]
b_array = [4,1,2]
b_matrix = Matrix.rows [
                          [1,0,0,-1,3,-5,3,1,2],
                          [1,1,1,0,-1,0,-4,1,0],
                          [0,0,1,2,4,1,-5,1,2]
                      ]

x_vector = Matrix.column_vector [0,3,1,1,0,0,0,0,0]
d_vector_row = Matrix.row_vector [4,-1,6]
c_vector = -2 * d_vector_row * b_matrix
d_matrix = 2 * b_matrix.t * b_matrix

j_fund = [1,2,3]
j_star = [1,2,3]
# d_matrix = Matrix.build(9){0}
# c_vector = Matrix.column_vector Array.new(9){1}

c_vector = c_vector.t
data = SquareBaseTaskData.new(c_vector, b_array, a_matrix, d_matrix, x_vector,j_fund, j_star)
solver = Solver.new
result = solver.solve(data)

if (result.nil?)
  puts solver.error_msg
else
  puts "x = {#{result.column(0).to_a.map{|e| e.round(5).to_f}.join(', ')}}"
end