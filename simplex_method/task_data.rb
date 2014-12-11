class TaskData
  require 'matrix'
  require 'logger'
  require_relative '../inverse_matrix/inverse_matrix_finder'

  # @param [Matrix] a_matrix матрица коэффициентов условий
  # @param [Matrix] c_vector вектор c. Передавать как Matrix.row_vector
  # @param [Matrix] b_vector вектор b. Передавать как Matrix.column_vector
  # @param [Array] x_basis массив-базисный план начальный. Задавать полностью. От него будет строиться множество базисных индексов
  def initialize(a_matrix, b_vector, c_vector, x_basis)
    @logger = Logger.new STDOUT
    @a_matrix = a_matrix
    @b_vector = b_vector
    @c_vector = c_vector
    @x_basis = x_basis
    @j_full = Array.new(x_basis.size){ |e| e }
    @j_basis = define_j_basis_indexes
    @j_not_basis = @j_full - @j_basis
    @c_basis = define_c_basis
    @a_basis_matrix = calculate_a_basis_matrix
    @b_matrix = calculate_b_matrix
  end

  def define_c_basis
    c_arr = []
    @j_basis.each { |e| c_arr << c_vector[0,e] }
    Matrix.row_vector c_arr
  end

  def define_j_basis_indexes
    j_basis_array = []
    @x_basis.each_with_index { |e,i| j_basis_array << i if e != 0 }
    j_basis_array
  end

  def calculate_b_matrix
    inverse_matrix_finder = InverseMatrixFinder.new
    res = inverse_matrix_finder.find_inverseMatrix @a_basis_matrix
    # res = @a_basis_matrix.inverse

    @logger.fatal(inverse_matrix_finder.get_error) if res.nil?
    res
  end

  def calculate_a_basis_matrix
    source_columns = @a_matrix.column_vectors.map(&:to_a)
    new_columns = []
    @j_basis.each { |e| new_columns << source_columns[e] }
    Matrix.columns new_columns
  end

  attr_reader :a_matrix, :a_basis_matrix, :b_vector, :c_vector, :c_basis, :x_basis,  :b_matrix,
              :j_basis, :j_full, :j_not_basis

end