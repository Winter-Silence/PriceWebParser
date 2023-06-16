# frozen_string_literal: true

class DateTimeFormatter < ApplicationHelper
  def self.to_human(date_time)
    date_time ? I18n.l(date_time.to_time, :format => '%e %b %Y %H:%M') : ''
  end
end
