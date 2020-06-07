r_env = ENV['RAILS_ENV']
if (r_env == 'production')
  require 'pg'
  require 'aws-sdk-ssm'

  conn_hash = {
    :host => 'localhost',
    :port => '5432',
    :dbname => '',
    :user => '',
    :password => '',
    :connect_timeout => 5,
    :client_encoding => 'auto'
  }

  client = Aws::SSM::Client.new(
    region: 'eu-west-2',
  )

  client.get_parameters_by_path({
    path: "/db/#{r_env}/alpha-blog/",
    recursive: false,
    with_decryption: true,
  })[0].each do | cfg |
    case cfg[:name].split("\/")[-1]
      when "connect_timeout"
        conn_hash[:connect_timeout] = cfg[:value].to_i
      when "user"
        conn_hash[:user] = cfg[:value]
      when "password"
        conn_hash[:password] = cfg[:value]
      when "host"
        conn_hash[:host] = cfg[:value]
      when "port"
        conn_hash[:port] = cfg[:value]
      when "dbname"
        conn_hash[:dbname] = cfg[:value]
    end
  end

  puts "Attempting to connect to postgresql://#{conn_hash[:user]}:filtered_pwd@#{conn_hash[:host]}:#{conn_hash[:port]}/#{conn_hash[:dbname]}"
  if (resp = PG::Connection.ping(conn_hash)) == 2
    puts "aws postgresdb is unreachable (error: #{resp})"
  else
    puts "Connection successful."
    puts "Setting ENV DATABASE_URL"
    ENV['DATABASE_URL'] = "postgresql://#{conn_hash[:user]}:#{conn_hash[:password]}@#{conn_hash[:host]}:#{conn_hash[:port]}/#{conn_hash[:dbname]}"
    puts "ENV['DATABASE_URL'] = has been completed."
  end
end
