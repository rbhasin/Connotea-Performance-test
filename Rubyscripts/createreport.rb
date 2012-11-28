class CreateReport
  
  # CreateReport
  #
  # Creates the flat HTML report based on the metrics collated from the CollateData class
  
  def self.create(filename)
    print 'Building report...'
    
    # Instantiate a summary object to collate the .csv file for use later on in the report
    
    summaryreport = Summary.new "./" + filename

    # Create the HTML head to set the Javascript for the graphs and the styling for the page
    
    header = "<html>
             <head>
             <title>Performance Report</title>
             <script src='http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js' type='text/javascript'></script>
             <script src='./js/highcharts.src.js' type='text/javascript'></script>"
   
    header += self.create_timechart(summaryreport)
    header += self.create_failchart(summaryreport)
             
    header += "<style type='text/css'>
                html {
                  font-family: trebuchet ms, verdana, tahoma, arial;
                }
                h1, h2 {
                  text-align: center;
                }
               table {
                 font-size: 0.8em;
                 border-collapse: collapse;
                 margin-left: auto;
                 margin-right: auto;        
               }
               p {
                 background: #F9F9F9;
                 border: 1px solid #DDD;
                 color: #666;
                 font-size: 0.7em;
                 padding: 5px;
                 margin-left: auto;
                 margin-right: auto;        
                 width: 700px;
               }
              th {
                 width: 125px;
                 height: 40px;
                 border-top: 1px solid #ccc;
                 border-bottom: 1px solid #ccc;
                 background-color: #ddd;          
              }
              td {
                 text-align: center;
                 border-bottom: 1px solid #ccc;
              }
              tr:hover{
                 background-color: #ccc;
              }
             </style>
             </head>
             <body>"

    # Create the HTML data format the two graphs
    
    charts = "<h1>Performance test results - Naturejobs</h1>
              <h2>Time-based Analysis: Page Duration</h2>
              <p>The Page Duration chart shows the minimum, maximum and average page duration for all pages in the test relative to the elapsed test time (sample period) in which they completed. Note that the page duration includes the time required to retrieve all resources for the page from the server. It includes network transmission time but not browser rendering time. In a well-performing system, the page durations should remain below the required limits up to or beyond the required load (number of users), subject to the performance requirements set forth for the system.</p>
              <div id='timeChart' style='width: 1300px; height: 500px; margin-left: auto; margin-right: auto;'></div>
              <h2>Time-based Analysis: Failure Rate</h2>
              <p>The failures section chart illustrates how the total number of page failures and the total page failure rate changed throughout the test relative to the elapsed test time in which they occurred. A page can fail for any number of reasons, including failures in the network and servers (web, application or database). In a well-performing system, this number should be zero.</p>
              <div id='failChart' style='width: 1300px; height: 500px; margin-left: auto; margin-right: auto;'></div>"

    # Create the Summary table 
    
    summarytable = "<h2>Performance summary metrics</h2><p>Sorted by the elapsed test time, this table shows some of the key metrics that reflect the performance of the test as a whole.</p>"

    # Call create_summary_report to create the tabled version of the results
    
    summarytable += summaryreport.create_summary_report

    # Finish off the HTML
    
    footer = "</body>
              </html>"

    # Concatenate the HTML strings and write them to into report.html
    
    File.open('./web/report.html','w'){|f| f.write(header + charts + summarytable + footer)}

    puts 'Done!'

  end

private  
  
  def self.create_timechart(data,name='timeChart')
    timechart = "<script type='text/javascript'>
                   $(document).ready(function() {
                     var " + name + " = new Highcharts.Chart({
                       chart: {
                         renderTo: '" + name + "',
                         type: 'line',
                         zoomType: 'x'            
                       },
                       title: {
                         text: null
                       },
                       xAxis: {
                         maxZoom: 10,         
                         labels: {
                           step: 20
                         },
                         categories: [" + data.create_time_array + "]
                       },
                       yAxis: [{
                         title: {
                           text: 'Time elapsed'
                         }
                       }, {
                         title: {
                           text: 'Users connected'
                         },
                         opposite: true,
                       }],
                       plotOptions: {
                         series: {
                           marker: {
                             enabled: false
                           }
                         }
                       },
                       tooltip: {
                       crosshairs: true,
                         shared: true
                       },
                       series: [{
                         name: 'Min response time',
                         data: [" + data.create_min_response_array + "]
                       }, {
                         name: 'Max response time',
                         data: [" + data.create_max_response_array + "]
                       }, {
                         name: 'Avg response time',
                         data: [" + data.create_avg_response_array + "]
                       }, {
                         name: 'Users connected',
                         yAxis: 1,
                         data: [" + data.create_user_count_array + "]
                       }]
                     });
                   });
               </script>"
    
    return timechart
  end
  
  def self.create_failchart(data,name='failChart')
    failchart = "<script type='text/javascript'>
                   $(document).ready(function() {
                   var " + name + " = new Highcharts.Chart({
                   chart: {
                     renderTo: '" + name + "',
                     type: 'line',
                     zoomType: 'x'           
                   },
                   title: {
                     text: null
                   },
                   xAxis: {
                     maxZoom: 10,
                     labels: {
                       step: 20
                     },
                     categories: [" + data.create_time_array + "]
                   },
                   yAxis: [{
                     title: {
                       text: 'Time elapsed'
                     }
                   }, {
                     title: {
                       text: 'Users connected'
                     },
                     opposite: true,
                   }],
                   tooltip: {
                     crosshairs: true,
                     shared: true
                   },
                   plotOptions: {
                     series: {
                       marker: {
                         enabled: false
                       }
                     }
                   },
                   series: [{
                     name: 'Failed rate',
                     data: [" + data.create_fail_rate_array + "]
                   }, {
                     name: 'Total failure rate',
                     data: [" + data.create_max_fail_rate_array + "]
                   }, {
                     name: 'Users connected',
                     yAxis: 1,
                     data: [" + data.create_user_count_array + "]
                   }]
                   });
                 });
               </script>"
    
    return failchart
  end
  
end