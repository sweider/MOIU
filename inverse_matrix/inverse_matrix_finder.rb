class InverseMatrixFinder
  require 'matrix'
  require_relative '../utils/ek_vector_factory'
  require_relative '../utils/d_matrix_factory'

  def initialize
    @error_msg = nil
    @c_matrix = Matrix[]
    @b_matrix = Matrix[]
    @source_matrix = Matrix[]
    @j_array = []
    @s_array = []
    @size = 0;
  end

  # Методом, описаным в метOде ищет обратную матрицу
  # @param [Matrix] source_matrix матрица, для которой ищем обратную
  # @return [Matrix] возвращает обратную матрицу, если она может быть найдена. Если нет -- nil. Ошибку можно получить по методу .get_error
  def find_inverseMatrix(source_matrix)
    @error_msg = nil
    if reinitialize source_matrix
      if solve_first_part
        repair_order
        @b_matrix
      else
        nil
      end
    else
      nil
    end
  end



  def get_error
    @error_msg
  end

  protected
  # @param [Matrix] source_matrix матрица, для которой ищем
  def reinitialize(source_matrix)
    if source_matrix.square?
      @size = source_matrix.row_count
      @c_matrix = Matrix.I(@size).map(&:to_r)
      @b_matrix = Matrix.I(@size).map(&:to_r)
      @source_matrix = source_matrix
      @j_array = Array.new(@size){ |i| i }
      @s_array = Array.new(@size)
      true
    else
      @error_msg = 'Source matrix isn\'t square'
      false
    end
  end

  # Выполняет первую часть решения -- до перестановки.
  # @return [Boolean] false if any error occurred, true otherwise
  def solve_first_part
    current_iteration = 0
    loop do
      a_index = get_first_not_zero_a_index(current_iteration + 1)
      if a_index.nil?
        @error_msg = "Cannot find a != 0 for iteration #{current_iteration} => determinant is 0"
        break
      else
        @j_array.delete(a_index)
        @s_array[a_index] = current_iteration
        update_c_matrix_column(@source_matrix.column(a_index),current_iteration)
        d_matrix = DMatrixFactory.get_DMatrix(
            @size,
            current_iteration,
            (@b_matrix * Matrix.column_vector(@c_matrix.column(current_iteration))).column(0)
        )
        @b_matrix = d_matrix * @b_matrix
      end
      current_iteration += 1
      break if !@error_msg.nil? || current_iteration >= @size
    end
    @error_msg.nil?
  end

  def get_first_not_zero_a_index(ek_index)
    a_index = -1;
    @j_array.each do |i|
      a = (EKVectorFactory.getEKRowVector(@size, ek_index - 1) * @b_matrix * Matrix.column_vector(@source_matrix.column(i)).map(&:to_r))[0,0]
      if(a != 0)
        a_index = i;
        break
      end
    end
    a_index != -1 ? a_index : nil
  end

  def repair_order
    true_ordered_rows = []
    @s_array.each_index { |i| true_ordered_rows << @b_matrix.row(@s_array[i]) }
    @b_matrix = Matrix.rows true_ordered_rows
  end

  # Устанавливает для матрицы C заданный столбец в заданное место
  def update_c_matrix_column(array, index)
    columns = @c_matrix.transpose.to_a
    columns[index] = array
    @c_matrix = Matrix.columns(columns)
  end
end