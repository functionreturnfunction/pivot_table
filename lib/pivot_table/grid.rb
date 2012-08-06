module PivotTable
  class Grid
    DEFAULT_SORT_ATTRIBUTE = :to_s

    attr_accessor :source_data, :row_name, :column_name, :column_sort_attribute, :row_sort_attribute
    attr_reader :columns, :rows, :data_grid

    def initialize(&block)
      self.column_sort_attribute = DEFAULT_SORT_ATTRIBUTE
      self.row_sort_attribute = DEFAULT_SORT_ATTRIBUTE
      yield(self) if block_given?
    end

    def build
      populate_grid
      build_rows
      build_columns
      self
    end

    def build_rows
      @rows = []
      @data_grid.each_with_index do |data, index|
        @rows << Row.new(:header => row_headers[index], :data => data)
      end
    end

    def build_columns
      @columns = []
      @data_grid.transpose.each_with_index do |data, index|
        @columns << Column.new(:header => column_headers[index], :data => data)
      end
    end

    def column_headers
      headers @column_name, column_sort_attribute
    end

    def row_headers
      headers @row_name, row_sort_attribute
    end

    def prepare_grid
      @data_grid = []
      row_headers.count.times do
        @data_grid << column_headers.count.times.inject([]) { |col| col << nil }
      end
      @data_grid
    end

    def populate_grid
      prepare_grid
      row_headers.each_with_index do |row, row_index|
        current_row = []
        column_headers.each_with_index do |col, col_index|
          current_row[col_index] = @source_data.find { |item| item.send(row_name) == row && item.send(column_name) == col }
        end
        @data_grid[row_index] = current_row
      end
      @data_grid
    end

    private

    def headers method, sort_attribute
      @source_data.collect { |c| c.send method }.uniq.sort_by { |obj| obj.send sort_attribute }
    end
  end
end
