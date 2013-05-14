module ApplicationHelper
  def previous_label(label)
    label.empty? ? "<" : label
  end

  def next_label(label)
    label.empty? ? ">" : label
  end
end
