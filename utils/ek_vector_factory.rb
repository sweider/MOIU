class EKVectorFactory
  require 'matrix'
  # Возвращает единичный n вектор с единицей на месте k
  # @return [Vector]
  # @param [Integer] n размерность вектора
  # @param [Integer] k позиция, на которой ставится единица, считается с нуля
  def self.getEKRowVector(n,k)
    array = []
    (0..n - 1).each { |i| array << (i == k ? 1 : 0) }
    Matrix::row_vector(array).map(&:to_r)
  end
end