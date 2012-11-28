class CollateData
  
  def self.create_full_site_report(params,filename)
    print 'Converting .jtl file into .csv file...'
    
    # Set variables for the function
    data = []
    count = 0
    csv_data = []
    csvcount = 0 
    
    # Open the report.jtl file
    doc = Nokogiri::XML(open("./report.jtl"))
    
    # Find all instances of the httpSample xml entry
    loop = doc.xpath('//httpSample')
    
    # Find all instances of the url entry
    urlarray = doc.xpath('//java.net.URL')
    
    # For every entry of httpSample loop through them and pull them apart
    loop.each do |i|
      tmphash = {} # Setup blank hash to break the xml off into
      
      # For each attribute that has been set loop through the httpSample extracting
      # that attribute
      params[:attributes].each do |a|
        case a
          # When the attribute equals url pull the url from urlarray and strip the
          # XML tags from it and remove the query string.  Then store it in tmphash
          when 'url'
            url = urlarray[count]
            url = url.to_s.gsub('<java.net.URL>','')
            url = url.gsub('</java.net.URL>','')
            url = url.split('?')
            tmphash[a.to_sym] = '\'' + url[0] + '\''
          # When the attribute equals tn take the Thread name from the XML and strip
          # the thread count and add it to tmphash
          when 'tn'
            tmphash[a.to_sym] = i.attr(a).gsub(i.attr(a)[/ [0-9]{1,3}-[0-9]{1,3}/],'')
          # When the attribute equals tn_no take the Thread name from the XML and
          # keep the thread count and strip the name out and add it to tmphash
          when 'tn_no'
            tmphash[a.to_sym] = i.attr(:tn)[/[0-9]{1,3}-[0-9]{1,3}/]
          # Else if the attribute equals none of the above, simply find the value of
          # the attribute you want to find and add it to tmphash
          else
            tmphash[a.to_sym] = i.attr(a)
        end
      end
      # Put tmphash into data array for further conversion later
      data[count] = tmphash
      
      # Increase the count for the next URL and data array entry
      count += 1
    end
    
    # Sort the data by timestamp attribute
    data = data.sort_by { |k| k[:ts] }

    # Set the initial timestamp to use for setting a new timestamp
    base_time = data[0][:ts]
    time_count = 0

    # Loop through the data updating the time stamp by subtracting the current
    # timestamp with the base timestamp
    data.each do |c|
      new_time = c[:ts].to_i - base_time.to_i
      data[time_count][:ts] = new_time.to_s
      time_count += 1
    end
    
    # Loop data to convert the hash entries into CSV formatted data

    data.each do |time|
      tmpcsvdata = []
      tmpcsvcount = 0
      
      params[:attributes].each do |attr|
        tmpcsvdata[tmpcsvcount] = time[attr.to_sym]
        tmpcsvcount += 1
      end
        
      csv_data[csvcount] = tmpcsvdata
      csvcount += 1
    end
    
    # Add the attributes list to the top of the csv file and then add each line
    # of csv_data processed from the convert to csv function
    
    csvfile = CSV.generate do |csv|
      csv << params[:attributes]
      csv_data.each do |entry|
        csv << entry
      end
    end
    
    # Open a data.csv and write the resulting csv content into the data.csv
    File.open(filename, 'w') {|f| f.write(csvfile)}
    
    puts 'Done!'
  end

end