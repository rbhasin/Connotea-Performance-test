 # Summary
  #
  # Summary class handles processing the data from a .csv file (created by the CollateData class) this includes
  # rendering the data into table format or working out averages for graphs.
  
  class Summary

    # initialize
    #
    # Imports a .csv file and groups the all the entries into groups of ten seconds
    
    def initialize loc
      # Import the .csv file
      rawdata = CSV.read(loc)

      # Set a base timestamp, blank array to store data in, intial timestamp
      @groupeddata = []
      
      timestamp = 10000
      tmpgroupdata = []

      rawdata.each do |entry|
        if entry[0] != 'ts'
          if entry[0].to_i <= timestamp
            tmpgroupdata << entry
          else
            @groupeddata << tmpgroupdata
            tmpgroupdata = []
            timestamp += 10000
            tmpgroupdata << entry
          end
        end
      end
    end

    # create_summary_report
    #
    # Creates an HTML table summary report of the data analysed, grouping it in
    # 10 second groups for each row.
    
    def create_summary_report
      @total_fails = 0
      @total_samples = 0
      count = 10
      table = "<table>\n<tr id='header'><th>Time</th><th>Users</th><th>Pages/sec</th><th>Page fail rate</th><th>Total fail rate</th><th>Min Page Dur</th><th>Avg Page Dur</th><th>Max Page Dur</th></tr>\n"

      @groupeddata.each do |data|
        table += "<tr><td>" + current_time(count) + "</td><td>" + user_count(data) + "</td><td>" + pages_per_second(data.count) + "</td><td>" + page_fail_rate(data) + "%</td><td>" + total_fail_rate(data) + "%</td><td>" + min_page_duration(data) + "</td><td>" + avg_page_duration(data) + "</td><td>" + max_page_duration(data) + "</td></tr>\n"
        count += 10
      end

      table += "</table>"
      
      return table
    end

    # create_time_array
    #
    # Takes the timestamp data from the analysed data and uses current_time to
    # summarise it into a string for use in Graphs in the HTML report
    
    def create_time_array
      arraytext = ""
      count = 10
      ac = @groupeddata.count
      cc = 1

      @groupeddata.each do |data|
        arraytext += "'" + current_time(count) + "'"
        arraytext += "," if cc < ac
        cc += 1
        count += 10
      end

      return arraytext
    end

    # create_user_count_array
    #
    # Takes the amount of users connected data from the analysed data and uses 
    # user_count to summarise it into a string for use in Graphs in the HTML report
    
    def create_user_count_array
      arraytext = ""
      ac = @groupeddata.count
      cc = 1

      @groupeddata.each do |data|
        arraytext += user_count(data)
        arraytext += "," if cc < ac
        cc += 1
      end

      return arraytext
    end 

    # create_min_response_array
    #
    # Takes the response data from the analysed data and uses min_page_duration
    # to identify the smallest response for each group of data and turn it into 
    # a string for use in Graphs in the HTML report
    
    def create_min_response_array
      arraytext = ""
      ac = @groupeddata.count
      cc = 1

      @groupeddata.each do |data|
        arraytext += min_page_duration(data)
        arraytext += "," if cc < ac
        cc += 1
      end

      return arraytext
    end

    # create_max_response_array
    #
    # Takes the response data from the analysed data and uses max_page_duration
    # to identify the largest response for each group of data and turn it into 
    # a string for use in Graphs in the HTML report
    
    def create_max_response_array
      arraytext = ""
      ac = @groupeddata.count
      cc = 1

      @groupeddata.each do |data|
        arraytext += max_page_duration(data)
        arraytext += "," if cc < ac
        cc += 1
      end

      return arraytext
    end

    # create_avg_response_array
    #
    # Takes the response data from the analysed data and uses avg_page_duration
    # to identify the average response for each group of data and turn it into 
    # a string for use in Graphs in the HTML report
    
    def create_avg_response_array
      arraytext = ""
      ac = @groupeddata.count
      cc = 1

      @groupeddata.each do |data|
        arraytext += avg_page_duration(data)
        arraytext += "," if cc < ac
        cc += 1
      end

      return arraytext
    end 

    # create_fail_rate_array
    #
    # Takes the amount of users connected data from the analysed data and uses 
    # page_fail_rate for each group of data to summarise it into a string for 
    # use in Graphs in the HTML report
    
    def create_fail_rate_array
      arraytext = ""
      ac = @groupeddata.count
      cc = 1

      @groupeddata.each do |data|
        arraytext += page_fail_rate(data)
        arraytext += "," if cc < ac
        cc += 1
      end

      return arraytext
    end

    # create_max_fail_rate_array
    #
    # Takes the amount of users connected data from the analysed data and uses 
    # total_fail_rate for the complete test of data to summarise it into a string 
    # for use in Graphs in the HTML report
    
    def create_max_fail_rate_array
      @total_fails = 0
      @total_samples = 0
      arraytext = ""
      ac = @groupeddata.count
      cc = 1

      @groupeddata.each do |data|
        arraytext += total_fail_rate(data)
        arraytext += "," if cc < ac
        cc += 1
      end

      return arraytext
    end

  private

    attr_accessor :groupeddata   # Holds the imported csv data that has been grouped into 10 second intervals
    attr_accessor :total_fails   # Holds the amount of requests that failed across the whole test
    attr_accessor :total_samples # Holds the amount of samples requested across the whole test
    
    # current_time
    #
    # Returns the time of the counted group from a base time of 00:00:00
    
    def current_time(t)
      basetime = Time.new(2008,6,21, 0,0,0, "+00:00")
      t2 = basetime + t

      return t2.strftime("%H:%M:%S")
    end
    
    # user_count
    # 
    # Returns the amount of Users connected in a 10 second sample by counting
    # the amount of users in the group
    
    def user_count(d)
      c = d.count
      return d[c - 1][4]
    end

    # pages_per_second
    #
    # Returns the amount of pages divided by the time elapsed in the group
    # (Currently 10 seconds)
    
    def pages_per_second(d)
      return (d / 10.0).to_s
    end

    # page_fail_rate
    #
    # Returns the amount of page fails found in a group by counting the error
    # counts and dividing by the amount of requests made
    
    def page_fail_rate(d)
      erc = 0
      d.each do |er|
        erc += 1 if er[7] == '1'
      end

      return (Float(erc) / Float(d.count)).round(2).to_s
    end
    
    # total_fail_rate
    #
    # Returns the amount of page fails that have occurred up that point in the test
    # by taking the amount of page fails and dividing it by the amount of requests
    # made during the test
    
    def total_fail_rate(d)
      d.each do |er|
        @total_fails += 1 if er[7] == '1'
        @total_samples += 1
      end
      return (Float(@total_fails) / Float(@total_samples)).round(2).to_s
    end

    # min_page_duration
    # 
    # Loops through an array to find the smallest response time within a group
    
    def min_page_duration(d)
      ts = 100000000000.00

      d.each do |it|
        ts = it[5].to_i if it[5].to_i < ts
      end

      return (Float(ts) / 1000).to_s
    end

    # avg_page_duration
    # 
    # Loops through an array adding all response times and dividing them by
    # amount of response in a group to return a mean average.  Rounded to the 
    # third decimal place
    
    def avg_page_duration(d)
      avgt = 0.0

      d.each do |it|
        avgt += it[5].to_i
      end

      average = (avgt / Float(d.count))
      return (average / 1000).round(3).to_s
    end

    # max_page_duration
    # 
    # Loops through an array to find the largest response time within a group
    
    def max_page_duration(d)
      ts = 0

      d.each do |it|
        ts = it[5].to_i if it[5].to_i > ts
      end

      return (Float(ts) / 1000).to_s
    end

end
