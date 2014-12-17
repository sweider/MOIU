class SquareBaseTaskData
  require 'matrix'
  attr_reader :x_vector, :x_star_array,
              :c, :c_fund, :c_x,
              :a_matrix, :a_matrix_fund, :a_star_matrix,
              :d_matrix, :d_star_matrix, :d_star_rows_matrix,
              :j_fund,:j_star, :j_not_star

  # @param [Matrix] c_source
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
    reinitialize(x_vector, j_fund, j_star)
  end


  def reinitialize(x_vector, j_fund, j_star)
    @x_vector = x_vector
    @j_full = Array.new(@x_vector.row_size) { |e| e }
    @j_fund = j_fund
    @j_star = j_star
    @j_not_star = @j_full.clone.delete_if { |e| @j_star.include?(e) }
    @x_star_array = [];
    x_vector.each_with_index { |e,i| @x_star_array << e if @j_star.include?(i)}
    prepare_data
  end

  protected
  def prepare_data
    prepare_c
    prepare_a_matrix_fund
    prepare_star_matrices
  end

  def prepare_star_matrices
    @d_star_matrix = form_bounded_matrix(@d_matrix, @j_star)
    @d_star_rows_matrix = form_rows_bounded_matrix(@d_matrix, @j_star)
    @a_star_matrix = column_bounded_matrix(@a_matrix, @j_star)
  end

  def column_bounded_matrix(matrix, array_of_indexes)
    columns = matrix.column_vectors.map(&:to_a)
    new_columns = []; array_of_indexes.each {|i| new_columns << columns[i]}
    Matrix.columns  new_columns# columns.select!{|col| array_of_indexes.include?(columns.index(col))}
  end

  def form_rows_bounded_matrix(d_matrix, array_of_indexes)
    old_rows = d_matrix.row_vectors.map(&:to_a)
    rows = []; array_of_indexes.each {|i| rows << old_rows[i]}
    # rows = d_matrix.row_vectors.map(&:to_a)
    Matrix.rows rows#rows.select!{|row| array_of_indexes.include?(rows.index(row))}
  end

  # Функция, возвращает матрицу, выбранную из исходной по следующему правилу --
  # эту матрицу составляют столбцы и строки, чьи индексы в исходной матрице присутсвтвуют
  # в массиве допустимых индексов
  # @param [Matrix] source_matrix
  # @param [Array] array_of_indexes массив индексов, по которым будет выбрана итоговая матрица
  def form_bounded_matrix(source_matrix, array_of_indexes)
    old_columns = source_matrix.column_vectors.map(&:to_a)
    new_columns = []
    array_of_indexes.each {|i| new_columns << old_columns[i]}
    # new_columns = old_columns.select { |col| array_of_indexes.include?(old_columns.index(col)) }
    temp_rows = Matrix.columns(new_columns).row_vectors.map(&:to_a)
    new_rows = []
    array_of_indexes.each {|i| new_rows << temp_rows[i]}
    # new_rows = temp_rows.select { |row| array_of_indexes.include?(temp_rows.index(row)) }
    Matrix.rows new_rows
  end

  def prepare_a_matrix_fund
    columns = @a_matrix.column_vectors.map(&:to_a)
    new_columns = columns.select { |col| @j_fund.include?(columns.index(col)) }
    @a_matrix_fund = Matrix.columns new_columns
  end

  def prepare_c
    @c_x = (@c + @d_matrix * @x_vector)
    c_x_array = c_x.column(0).to_a
    c_fund_array = []; c_x_array.each_with_index {|e,i| c_fund_array << e if (@j_fund.include?(i))}
    @c_fund = Matrix.column_vector c_fund_array
  end
end