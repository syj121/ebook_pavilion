module ActiveRecordPlus
  extend ActiveSupport::Concern

  def error_msgs
    errors.values.flatten.join(" ")
  end
end