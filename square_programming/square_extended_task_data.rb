require_relative 'square_base_task_data'
class SquareExtendedTaskData
  attr_reader :j0, :valuation_j0, :base_data

  # @param [Object] j0
  # @param [Object] valuation_j0
  # @param [SquareBaseTaskData] base_data
  def initialize(j0, valuation_j0, base_data)
    @j0 = j0
    @valuation_j0 = valuation_j0
    @base_data = base_data
  end
end