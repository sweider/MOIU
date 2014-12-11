require_relative 'simplex_method_solver'
require_relative 'task_data'
require 'matrix'


# a_matrix = Matrix.rows [[1,3,1,2],[2,0,-1,1]]
# a_matrix = Matrix.rows [
#                            [1.31, 19.11, 7.49, 0.428, 0.519,1,0,0,0,0,0],
#                            [1   , 0    , 0   , 0    , 0    ,0,1,0,0,0,0],
#                            [0   , 1    , 0   , 0    , 0    ,0,0,1,0,0,0],
#                            [0   , 0    , 1   , 0    , 0    ,0,0,0,1,0,0],
#                            [0   , 0    , 0   , 1    , 0    ,0,0,0,0,1,0],
#                            [0   , 0    , 0   , 0    , 1    ,0,0,0,0,0,1]
#                        ]
# b_vector = Matrix.column_vector [0,0,0,0,0,0,0,0,0,0,0]
# c_vector = Matrix.row_vector [0.262,3.822,1.498,0.0856,0.1032,0,0,0,0,0,0]
# x_basis = [0,2000,5000,0,0,30170,10000,0,0,30000,50000]
a_matrix = Matrix.rows [
                           [1,0,1,2,0,4,-3,8],
                           [1,1,0,2,0,5,4,12],
                           [1,0,0,2,1,2,1,6]
                       ]
b_vector = Matrix.column_vector [4,2,5]
c_vector = Matrix.row_vector [-1,-3,-2,-1,1,4,-3,-10]
x_basis = [0,2,4,0,5,0,0,0]
task_data = TaskData.new(a_matrix, b_vector, c_vector, x_basis)
simplex_method_solver = SimplexMethodSolver.new
solution = simplex_method_solver.solve task_data

if (solution.nil?)
  puts simplex_method_solver.error_msg
else
  puts "x = {#{solution.map{|e| e.round(3)}.join(', ')}}"
end