class PrettyPrinter
  # Выводит в консоль матрицу в виде матрицы, а не строки
  def self.print_matrix(matrix)
    matrix.row_vectors.each { |row| puts row.to_a.map{|e| e.round(3)}.join("\t") }
  end
end