class Array
  def deep_dup
    self.dup.tap do |dupped|
      dupped.each_with_index do |element, index|
        dupped[index] = element.respond_to?(:deep_dup) ? element.deep_dup : element
      end
    end
  end
end
