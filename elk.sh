# EK_VERSION=elasticsearch-5.3.0
# LS_VERSION=logstash-5.3.0
# KIBANA_VERSION=kibana-6.3.0
# REDIS_VERSION=redis-4.0.10

_HOME=~/elk #/opt/


_elksetup(){
    if [ ! -d "elasticsearch-5.3.0" ]; then
    	wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.3.0.tar.gz
        tar -xf elasticsearch-5.3.0.tar.gz
        #rm elasticsearch-5.3.0.tar.gz
	fi

    if [ ! -d "logstash-5.3.0" ]; then
       wget https://artifacts.elastic.co/downloads/logstash/logstash-5.3.0.tar.gz
   	   tar -xf logstash-5.3.0.tar.gz
   	   #rm logstash-5.3.0.tar.gz
	fi	

	if [ ! -d "kibana-6.3.0" ]; then
    	wget https://artifacts.elastic.co/downloads/kibana/kibana-6.3.0-linux-x86_64.tar.gz
    	tar -xf kibana-6.3.0-linux-x86_64.tar.gz
	
    fi
	
	if [ ! -d "redis-4.0.10" ]; then
		wget http://download.redis.io/releases/redis-4.0.10.tar.gz
		tar -xf redis-4.0.10.tar.gz
		cd redis-4.0.10
		make
		#daemon
		sed -i 's/daemonize no/daemonize yes/' 	$_HOME/redis-4.0.10/redis.conf
		sed -i 's/# requirepass foobared/requirepass wyy/' 	$_HOME/redis-4.0.10/redis.conf

	fi
 }

 _ruby(){
 	echo "ruby"
 	#安装ruby
    #gem install protoc
	#gem install ruby-protocol-buffers
 }

 _test(){
 	echo "Test"
 	#sed -i 's/# requirepass foobared/requirepass wyy/' 	$_HOME/redis-4.0.10/redis.conf
 }

if [[ $1 = "git" ]]; then
	git clone https://github.com/arafat5549/elk.git
fi

if [[ $1 = "ruby" ]]; then
	_ruby
	#sed -i 's/daemonize no/daemonize yes/' 	$_HOME/redis-4.0.10/redis.conf
fi

if [[ $1 = "setup" ]]; then
 	_elksetup
fi

if [[ $1 = "state" ]]; then
  	psid=$(ps aux | grep elasticsearch-5.3.0 | awk '$11!="grep"{print $0}')
  	psid2=$(ps aux | grep logstash-5.3.0 | awk '$11!="grep"{print $0}')
	psid3=$(ps aux | grep redis | awk '$11!="grep"{print $0}')

	echo $psid
	echo $psid2
	echo $psid3

fi

if [[ $1 = "run" ]]; then
	#echo $_HOME

	cd $_HOME

	psid=$(ps aux | grep elasticsearch-5.3.0 | awk '$11!="grep"{print $2}')

	if [[ $psid != "" ]]; then
		echo "es is running"
		kill -9 $psid
	fi
	./elasticsearch-5.3.0/bin/elasticsearch -Ees.insecure.allow.root=true -d


	psid3=$(ps aux | grep redis | awk '$11!="grep"{print $2}')
	if [[ $psid3 != "" ]]; then
		echo "redis is running"
		kill -9 $psid3
	fi
	./redis-4.0.10/src/redis-server redis-4.0.10/redis.conf


	psid2=$(ps aux | grep logstash-5.3.0 | awk '$11!="grep"{print $2}')
	if [[ $psid2 != "" ]]; then
		echo "logstash is running"
		kill -9 $psid2
	fi
	./logstash-5.3.0/bin/logstash  -f conf/logstash.conf 

	echo $psid,$psid2,$psid3


fi

