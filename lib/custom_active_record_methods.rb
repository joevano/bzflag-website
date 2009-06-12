module CustomActiveRecordMethods
  def db_date(date)
    date && date.gmtime.strftime("%Y-%m-%d %H:%M:%S")
  end

  ActiveRecord::Base.extend(CustomActiveRecordMethods)
end
