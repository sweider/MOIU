require 'mathn'
require 'matrix'
class DMatrixFactory
  # @param [Integer] k индекс отличающегося столбца
  # @param [Vector] specific_vector собственно отличающийся вектор-столбец
  def self.get_DMatrix(matrix_size, d_vector_index, specific_vector)
    divider = -1.0/specific_vector[d_vector_index]
    d_vector = (specific_vector * divider).map { |e| e.to_f }.to_a
    d_vector[d_vector_index] = -1 * divider
    e_matrix = Matrix.I(matrix_size)
    columns_arrays = e_matrix.column_vectors.map { |v| v.to_a }
    columns_arrays[d_vector_index] = d_vector
    Matrix.columns(columns_arrays).map(&:to_r)
  end
end