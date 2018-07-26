# EK_VERSION=elasticsearch-5.3.0
# LS_VERSION=logstash-5.3.0
# KIBANA_VERSION=kibana-6.3.0
# REDIS_VERSION=redis-4.0.10

computer="";
_HOME="~/elk";
case "`uname`" in  
    CYGWIN*) computer="Cygwin" _HOME=~/elk;;
    Darwin*) computer="Darwin" _HOME=~/elk;;  
    (*Linux*) computer="Linux" _HOME=/opt;;  
esac

echo "HOME:"$_HOME

_elksetup(){
	#cd $EL_HOME
    if [ ! -d "elasticsearch-5.3.0" ]; then
    	if [[ ! -f "elasticsearch-5.3.0.tar.gz" ]]; then
    		wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.3.0.tar.gz
    	fi

    	tar -xf elasticsearch-5.3.0.tar.gz
    	_sed
	fi

    if [ ! -d "logstash-5.3.0" ]; then
    	if [[ ! -f "logstash-5.3.0.tar.gz" ]]; then
    		wget https://artifacts.elastic.co/downloads/logstash/logstash-5.3.0.tar.gz
    	fi
    	tar -xf logstash-5.3.0.tar.gz

	fi	

	if [ ! -d "kibana-6.3.0" ]; then
		if [[ ! -f "kibana-6.3.0-linux-x86_64.tar.gz" ]]; then
			wget https://artifacts.elastic.co/downloads/kibana/kibana-6.3.0-linux-x86_64.tar.gz
		fi
		tar -xf kibana-6.3.0-linux-x86_64.tar.gz

    fi
	
	if [ ! -d "redis-4.0.10" ]; then
		if [[ ! -f "redis-4.0.10.tar.gz" ]]; then
			wget http://download.redis.io/releases/redis-4.0.10.tar.gz
		fi

		tar -xf redis-4.0.10.tar.gz
		cd redis-4.0.10
		make
		#daemon
		sed -i 's/daemonize no/daemonize yes/' 	$_HOME/redis-4.0.10/redis.conf
		sed -i 's/# requirepass foobared/requirepass wyy/' 	$_HOME/redis-4.0.10/redis.conf
	fi
 }

_sed(){
	sed -i 's/-Xms2g/-Xms1g/' 	$_HOME/elasticsearch-5.3.0/config/jvm.options
	sed -i 's/-Xmx2g/-Xms1g/' 	$_HOME/elasticsearch-5.3.0/config/jvm.options
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

 _sec(){
	cd $_HOME
 	groupadd elsearch
	useradd elsearch -g elsearch -p elasticsearch-5.3.0
	chown -R elsearch:elsearch  elasticsearch-5.3.0
 }

if [[ $1 = "sec" ]]; then
	_sec
fi

if [[ $1 = "git" ]]; then
	git clone https://github.com/arafat5549/elk.git
fi

if [[ $1 = "ruby" ]]; then
	_ruby
	#sed -i 's/daemonize no/daemonize yes/' 	$_HOME/redis-4.0.10/redis.conf
fi

if [[ $1 = "setup" ]]; then
	#cd $_HOME
 	_elksetup
fi

if [[ $1 = "state" ]]; then
  	psid=$(ps aux | grep elasticsearch-5.3.0 | awk '$11!="grep"{print $0}')
  	psid2=$(ps aux | grep logstash-5.3.0 | awk '$11!="grep"{print $0}')
	psid3=$(ps aux | grep redis | awk '$11!="grep"{print $0}')

	echo $psid
	echo $psid2
	echo $psid3

	if [[ $2 = "kill" ]]; then
		if [[ $psid != "" ]]; then
			echo "kill es"
			kill -9 $psid
		fi

		if [[ $psid2 != "" ]]; then
			echo "kill logstash"
			kill -9 $psid2
		fi

		if [[ $psid3 != "" ]]; then
			echo "kill redis"
			kill -9 $psid3
		fi
	fi

fi

_es(){
	cd $_HOME
	psid=$(ps aux | grep elasticsearch-5.3.0 | awk '$11!="grep"{print $2}')
	if [[ $psid != "" ]]; then
		echo "es is running"
		kill -9 $psid
	fi
	 ./elasticsearch-5.3.0/bin/elasticsearch -d
}

_kibana(){
	cd $_HOME
	case "$1" in  
		sense) 
			./kibana-6.3.0-linux-x86_64/bin.kibana plugin --install elastic/sense
		 ;; 

		 run)
		 	./kibana-6.3.0-linux-x86_64/bin.kibana
		 ;;
		
	esac
}

# if [[ $1 = "es" ]]; then
#    _es
# fi

case "$1" in  
	es) _es ;;
    kibana)  _kibana $2 ;;
esac

if [[ $1 = "run" ]]; then
	#_es

	cd $_HOME
	psid3=$(ps aux | grep redis | awk '$11!="grep"{print $2}')
	if [[ $psid3 != "" ]]; then
		echo "redis is running"
		kill -9 $psid3
	fi
	./redis-4.0.10/src/redis-server $_HOME/redis-4.0.10/redis.conf


	psid2=$(ps aux | grep logstash-5.3.0 | awk '$11!="grep"{print $2}')
	if [[ $psid2 != "" ]]; then
		echo "logstash is running"
		kill -9 $psid2
	fi
	#./logstash-5.3.0/bin/logstash  -f ~/elk/conf/logstash.conf 
	nohup ./logstash-5.3.0/bin/logstash  -f ~/elk/conf/logstash.conf  &> /dev/null

	#echo $psid,$psid2,$psid3

fi

