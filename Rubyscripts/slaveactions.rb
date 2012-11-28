# upload_files
#
# Params:
#   String[] slaves
#   String   login
#   String   password
#
# For each slave IP given in an array to the function the function will open an
# SCP and SSH connection, kill any running versions of Java, upload test data
# and begin running jmeter-server

def upload_files(slaves,login,password)
  # Loop through each IP string
  slaves.each do |ip|
    @scp = Net::SCP.start(ip, login, :password => password) # Connect via SCP to box
    @ssh = Net::SSH.start(ip, login, :password => password) # Connect via SSH to box

    @ssh.exec!("killall -9 java") # Kill all running instances of Java on the box

    # Take all the .csv files from the test_data folder and copy them to the box
    
    Dir["./test_data/*.*"].each do |file|
      puts 'Uploading ' + file + ' to ' + ip
      @scp.upload! file, '/home/' + login + '/'
    end
    
    # Fork running Jmeter-server into another thread to prevent the main thread
    # getting stuck on waiting for Jmeter-server to close (which we don't want)
    
    @pid = fork{ 
      @ssh.exec!("/home/" + login + "/jmeter/bin/jmeter-server -Jlocation=/home/" + login + "/apache-jmeter-2.6/bin/") 
    }
  end
end

# teardown_files
#
# Params:
#   String[] slaves
#   String   login
#   String   password
#
# For each slave IP given in an array to the function the function will kill
# Jmeter-server by killing all instances of Java on the box, then delete all
# test data

def teardown_files(slaves,login,password)
  # Loop through each IP string
  slaves.each do |ip|
    @ssh = Net::SSH.start(ip, login, :password => password) # Connect via SSH to box

    puts @ssh.exec!("pskill java") # Kill all running instance of Java on the box
    
    puts 'Removing files from ' + ip
    
    location = "../test_data/"
    # Delete all test data
    Dir[location + "*.*"].each do |file|
      @ssh.exec!("rm /home/" + login + "/" + file.gsub(location,""))
    end
  end
end