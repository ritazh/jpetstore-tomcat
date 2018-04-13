#!/bin/sh
set -x
echo " **  Invoking Custom Assemble Script"

# Finds appropriate environment variable
function find_env() {                                                           
  var=`printenv "$1"`                                                           
  # If environment variable exists                                              
  if [ -n "$var" ]; then                                                        
    echo $var                                                                   
  else                                                                          
    echo $2                                                                     
  fi                                                                            
}  

# Generates the appropriate datasource based on input parameters from template
# $1 - datasource jndi name                                                     
# $2 - datasource username                                                      
# $3 - datasource password                                                      
# $4 - datasource driver                                                        
# $5 - datasource url  
function generate_datasource(){
  echo " <Resource name=\"$1\"\nusername=\"$2\"\npassword=\"$3\"\ndriverClassName=\"$4\"\nurl=\"$5\"\nauth=\"Container\"\ntype=\"javax.sql.DataSource\"\nmaxActive=\"20\"\nmaxIdle=\"5\"\nmaxWait=\"10000\" />"          
}

# Get Env Variables and Generate Config
driver="org.postgresql.Driver"
jndi=$(find_env "DB_JNDI")  
password=$(find_env "DB_PASSWORD")
username=$(find_env "DB_USERNAME")
database=$(find_env "DB_DATABASE")   
url="jdbc:postgresql://$(find_env "DB_HOST"):$(find_env "DB_PORT")/$(find_env "DB_DATABASE")"

datasources="$(generate_datasource $jndi $username $password $driver $url)\n\n"

C=$(echo $datasources | sed 's/\//\\\//g')
sed -i "/<\/Context>/ s/.*/${C}\n&/" $JWS_HOME/conf/context.xml

