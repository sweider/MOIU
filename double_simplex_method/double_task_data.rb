class DoubleTaskData
  require 'matrix'
  attr_reader :a_matrix, :b_vector, :c_vector, :b_matrix, :j_basis, :j_not_basis, :j_full, :y_plan, :size
# @param [Matrix] a_matrix
# @param [Matrix] b_vector
# @param [Array] c_vector
# @param [Array] y_plan
  def initialize(a_matrix, b_vector, c_vector, y_plan, j_basis)
    @size = a_matrix.column_size
    @y_plan = y_plan
    @a_matrix = a_matrix
    @b_vector = b_vector
    @c_vector = c_vector
    @j_basis = j_basis
    initialize_
  end

  def reinitialize(y_plan, j_basis)
    @y_plan = y_plan
    @j_basis = j_basis
    initialize_
  end

  protected
  def initialize_
    @j_full = Array.new(@size) { |e| e }
    @j_not_basis = @j_full.clone
    @j_not_basis.delete_if { |e| @j_basis.include?(e) }
    @a_basis_matrix = calculate_a_basis_matrix
    @b_matrix = @a_basis_matrix.inverse
  end

  def calculate_a_basis_matrix
    columns = []
    @j_basis.each { |e| columns << @a_matrix.column(e).to_a }
    Matrix.columns columns
  end


end