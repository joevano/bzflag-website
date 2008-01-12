# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def display_date(date)
    date && date.strftime("%Y-%m-%dT%H:%M:%SZ")
  end
end
