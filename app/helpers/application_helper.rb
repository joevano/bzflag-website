# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def display_date(date)
    date && date.strftime("%Y %b %d %H:%M:%S")
  end

  def display_date_range(d1, d2)
    range = display_date(d1)
    if d2
      range = range + " - "
      if d2.strftime("%Y") != d1.strftime("%Y")
        range = range + display_date(d2)
      elsif d2.strftime("%b") != d1.strftime("%b")
        range = range + d2.strftime("%b %d %H:%M:%S")
      elsif d2.strftime("%d") != d1.strftime("%d")
        range = range + d2.strftime("%d %H:%M:%S")
      else
        range = range + d2.strftime("%H:%M:%S")
      end
    end
    range
  end
end
