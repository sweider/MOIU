class SquareTaskData
  require 'matrix'
  attr_reader :x_vector,
              :c, :c_fund, :c_x,
              :a_matrix, :a_matrix_fund, :a_star_matrix,
              :d_matrix, :d_star_matrix,
              :j_fund,:j_star, :j_not_fund

  # @param [Array] c_source
  # @param [Array] b
  # @param [Matrix] a_matrix
  # @param [Matrix] d_matrix
  # @param [Matrix] x_vector
  # @param [Array] j_fund
  # @param [Array] j_star
  def initialize(c_source, b, a_matrix, d_matrix, x_vector, j_fund, j_star)
    @c = c_source
    @b = b
    @a_matrix = a_matrix
    @d_matrix = d_matrix
    @x_vector = x_vector
    @j_full = Array.new(@x_vector.size) { |e| e }
    @j_fund = j_fund
    @j_star = j_star
    @j_not_fund = @j_full.clone.delete_if { |e| @j_star.include?(e) }
    prepare_data
  end

  protected
  def prepare_data
    prepare_c
    prepare_a_matrix_fund
    prepare_star_matrices
  end

  def prepare_star_matrices
    @d_star_matrix = form_bounded_matrix(@d_matrix, @j_fund)
    @a_star_matrix = form_bounded_matrix(@a_matrix, @j_fund)

  end

  # Функция, возвращает матрицу, выбранную из исходной по следующему правилу --
  # эту матрицу составляют столбцы и строки, чьи индексы в исходной матрице присутсвтвуют
  # в массиве допустимых индексов
  # @param [Matrix] source_matrix
  # @param [Array] array_of_indexes массив индексов, по которым будет выбрана итоговая матрица
  def form_bounded_matrix(source_matrix, array_of_indexes)
    old_columns = source_matrix.column_vectors.map(&:to_a)
    new_columns = old_columns.select { |col| array_of_indexes.include?(old_columns.index(col)) }
    temp_rows = Matrix.columns(new_columns).row_vectors.map(&:to_a)
    new_rows = temp_rows.select { |row| array_of_indexes.include?(temp_rows.index(row)) }
    Matrix.rows new_rows
  end

  def prepare_a_matrix_fund
    columns = @a_matrix.column_vectors.map(&:to_a)
    new_columns = columns.select { |col| @j_fund.include?(columns.index(col)) }
    @a_matrix_fund = Matrix.columns new_columns
  end

  def prepare_c
    @c_x = (@c + @d_matrix * @x_vector).to_a
    @c_fund = Matrix.column_vector c_x.select { |e| @j_fund.include?(c_x.index(e)) }
  end
end