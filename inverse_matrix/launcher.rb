require_relative 'inverse_matrix_finder'
require_relative '../utils/pretty_printer'
source = Matrix.rows([[1,0,0],[2,1,0],[0,1,1]])

source = Matrix.rows([[0,2,1], [0,1,1], [1,1,1]])
# source = Matrix.rows [[1,1,1,1], [1,0,2,2], [2,0,2,4], [4,1,4,1]]
# source = Matrix.rows [[3,2],[1,2]]
# source = Matrix.rows [[4,0,0,0,1],[0,4,0,1,1],[0,0,4,3,2],[0,1,3,0,0],[1,1,2,0,0]]

source = Matrix.rows [
                         [19.11, 7.49, 1, 0, 0, 0],
                         [0    , 0   , 0, 1, 0, 0],
                         [1    , 0   , 0, 0, 0, 0],
                         [0    , 1   , 0, 0, 0, 0],
                         [0    , 0   , 0, 0, 1, 0],
                         [0    , 0   , 0, 0, 0, 1]
                      ]
source = Matrix.rows [
                         [2,-1,4,5,2.000001],
                         [1,1,1,-1,1],
                         [3,0,5,4,3],
                         [-9,6,3,5,1],
                         [7,4,9,1,8]
                     ]
source = source.map(&:to_r)
founder = InverseMatrixFinder.new()
solution = founder.find_inverseMatrix(source)
if(solution.nil?)
  puts founder.get_error
else
  PrettyPrinter.print_matrix solution
  puts 'Check:'
  PrettyPrinter.print_matrix source * solution
end