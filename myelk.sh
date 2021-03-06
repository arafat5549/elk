# EK_VERSION=elasticsearch-5.3.0
# LS_VERSION=logstash-5.3.0
# KIBANA_VERSION=kibana-6.3.0
# REDIS_VERSION=redis-4.0.10
NGINX_V=1.14.0

_HOME=~/elk 
computer="";
case "`uname`" in  
    CYGWIN*) computer="Cygwin" _HOME=~/elk;;
    Darwin*) computer="Darwin" _HOME=~/elk;;  
    (*Linux*) computer="Linux" _HOME=/opt;;  
esac

echo "HOME:"$_HOME


 _killproc(){
	psid=$(ps aux | grep $1 | awk '$11!="grep"{print $2}')
	if [[ $psid != "" ]]; then
		echo "$1 is running",$psid
		kill -9 $psid
	fi		
}
#--------------------------------------------------------------------------------------


 _ruby(){
 	echo "ruby"
 	#安装ruby
    #gem install protoc
	#gem install ruby-protocol-buffers
 }

 _security(){
	cd $_HOME
 	groupadd elsearch
	useradd elsearch -g elsearch -p elasticsearch-5.3.0
	chown -R elsearch:elsearch  elasticsearch-5.3.0
 }

 _sedfile(){
 	#origin=127.0.0.1
 	#ip=192.168.0.128
 	#redis
 	sed -i 's/bind 127.0.0.1/bind 192.168.0.128/' 	$_HOME/redis-4.0.10/redis.conf	
 	#sed -i 's/port 6379/port 6379/' 	$_HOME/redis-4.0.10/redis.conf	
 	#es
 	sed -i 's/#network.host: 192.168.0.1/network.host: 192.168.0.128/' $_HOME/elasticsearch-5.3.0/config/elasticsearch.yml
	sed -i 's/#http.port: 9200/http.port: 9200/' $_HOME/elasticsearch-5.3.0/config/elasticsearch.yml
	#logstash
 }



_redis(){
	cd $_HOME
	
	case "$1" in
		yml)
			sed -i 's/daemonize no/daemonize yes/' 	$_HOME/redis-4.0.10/redis.conf
			sed -i 's/# requirepass foobared/requirepass wyy/' 	$_HOME/redis-4.0.10/redis.conf	

			#sed -i 's/bind 127.0.0.1/bind 192.168.0.128/' 	$_HOME/redis-4.0.10/redis.conf	
			#open $_HOME/redis-4.0.10/redis.conf
		;;
		openconf)
			vim $_HOME/redis-4.0.10/redis.conf
		;;
		setup)
			if [ ! -f "redis-4.0.10.tar.gz" ]; then
				wget http://download.redis.io/releases/redis-4.0.10.tar.gz
			fi
			tar -xf redis-4.0.10.tar.gz
			cd redis-4.0.10
			make
		;;
		run) 
			#_killproc redis
			./redis-4.0.10/src/redis-server $_HOME/redis-4.0.10/redis.conf
		;;
		stop)
			_killproc redis
		;;
		cli)
			./redis-4.0.10/src/redis-cli -a wyy -h $2 -p 6379
		;;
	esac
}

_es(){
	cd $_HOME
	case "$1" in
		yml)
			sed -i 's/-Xms2g/-Xms1g/' 	$_HOME/elasticsearch-5.3.0/config/jvm.options
			sed -i 's/-Xmx2g/-Xms1g/' 	$_HOME/elasticsearch-5.3.0/config/jvm.options
			#open $_HOME/elasticsearch-5.3.0/config/elasticsearch.yml
		;;
		setup)
			wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.3.0.tar.gz
			tar -xf elasticsearch-5.3.0.tar.gz
		;;
		run) 
			_killproc elasticsearch
		 	./elasticsearch-5.3.0/bin/elasticsearch -d
		;;
		stop)
			_killproc elasticsearch
		;;
	esac
	
}

_logstash(){
	cd $_HOME
	case "$1" in
		yml)
			#open $_HOME/logstash-5.3.0/config/logstash.yml

		;;
		setup)
		    if [ ! -d "logstash-5.3.0" ]; then
		    	if [ ! -f "logstash-5.3.0.tar.gz" ]; then
		    		wget https://artifacts.elastic.co/downloads/logstash/logstash-5.3.0.tar.gz
		    	fi
		    	tar -xf logstash-5.3.0.tar.gz

			fi	
		;;
		run) 
			#_killproc logstash
			#./logstash-5.3.0/bin/logstash  -f $_HOME/mylogstash.conf 
			nohup $_HOME/logstash-5.3.0/bin/logstash  -f $_HOME/mylogstash.conf  &> /dev/null
		;;
		stop)
			_killproc logstash
		;;
	esac	
}

_zookeeper(){
	cd $_HOME
	case "$1" in
		yml)
			#sed -i 's/-Xms2g/-Xms1g/' 	$_HOME/elasticsearch-5.3.0/config/jvm.options
			#sed -i 's/-Xmx2g/-Xms1g/' 	$_HOME/elasticsearch-5.3.0/config/jvm.options
			#open $_HOME/elasticsearch-5.3.0/config/elasticsearch.yml
		;;
		setup)
			wget https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.4.10/zookeeper-3.4.10.tar.gz
			tar -xf zookeeper-3.4.10.tar.gz
		;;
		run) 
			#_killproc elasticsearch
		 	#./zookeeper-3.4.10/bin/elasticsearch -d
		;;
		stop)
			_killproc zookeeper
		;;
	esac
}

_kafka_conf(){
	brokerid=$1
	ipc=$2   
	sed -i "s/broker.id=0/broker.id=$brokerid/"  $_HOME/kafka_2.11-1.1.0/config/server.properties
	sed -i "s@#listeners=PLAINTEXT://:9092@listeners=PLAINTEXT://$ipc:9092@" $_HOME/kafka_2.11-1.1.0/config/server.properties
	sed -i "s/zookeeper.connect=localhost:2181/zookeeper.connect=$ipc:2181/" $_HOME/kafka_2.11-1.1.0/config/server.properties	

	sed -i "s/tickTime=2000//" $_HOME/kafka_2.11-1.1.0/config/zookeeper.properties
	sed -i "s/initLimit=10//" $_HOME/kafka_2.11-1.1.0/config/zookeeper.properties
	sed -i "s/syncLimit=5//" $_HOME/kafka_2.11-1.1.0/config/zookeeper.properties
	sed -i "s/server.$brokerid=$ipc:2888:3888//" $_HOME/kafka_2.11-1.1.0/config/zookeeper.properties
	sed -i "s/brokerid=$brokerid/broker.id=0/" $_HOME/kafka_2.11-1.1.0/config/zookeeper.properties

	echo "tickTime=2000" >> $_HOME/kafka_2.11-1.1.0/config/zookeeper.properties
	echo "initLimit=10" >> $_HOME/kafka_2.11-1.1.0/config/zookeeper.properties
	echo "syncLimit=5" >> $_HOME/kafka_2.11-1.1.0/config/zookeeper.properties
	echo "server.$brokerid=$ipc:2888:3888" >> $_HOME/kafka_2.11-1.1.0/config/zookeeper.properties

	sed -i "s/broker.id=0/broker.id=$brokerid/" /tmp/kafka-logs/meta.properties

	hname=$(hostname)
	echo "$ipc" >> /etc/hosts

}

_kafaka_test(){
	ipc=119.29.238.193
	#ipc2=10.135.108.183
	itopic=topic_cctt_kafka
	case "$1" in
	   topic)  	$_HOME/kafka_2.11-1.1.0/bin/kafka-topics.sh --create --zookeeper "$ipc:2181" --replication-factor 1 --partitions 1 --topic $itopic ;;
       list) 	$_HOME/kafka_2.11-1.1.0/bin/kafka-topics.sh --list --zookeeper "$ipc:2181" ;;
       prod)    $_HOME/kafka_2.11-1.1.0/bin/kafka-console-producer.sh --broker-list "$ipc:9092" --topic $itopic ;;
	   consume) $_HOME/kafka_2.11-1.1.0/bin/kafka-console-consumer.sh --bootstrap-server "$ipc:9092"  --topic $itopic --from-beginning;;
    esac 
}

_kafka(){
	cd $_HOME
	case "$1" in
		test)
			_kafaka_test 119.29.238.193:9092 test

		;;
		yml)
			sed -i 's/KAFKA_HEAP_OPTS="-Xmx1G -Xms1G"/KAFKA_HEAP_OPTS="-Xmx256M -Xms128M"/' 	$_HOME/kafka_2.11-1.1.0/bin/kafka-server-start.sh
			#sed -i 's/KAFKA_HEAP_OPTS="-Xmx512M -Xms512M"/KAFKA_HEAP_OPTS="-Xmx256M -Xms128M"/' 	$_HOME/kafka_2.11-1.1.0/bin/kafka-zookeeper-start.sh
		;;
		conf)
			if [ $2 == "1" ]; then
				_kafka_conf $2  119.29.238.193 #腾讯ip
			elif [ $2 == "2" ]; then
				_kafka_conf $2  35.229.142.60  #google ip
			fi
			
		;;
		setup)
		    if [ ! -d "kafka_2.11-1.1.0" ]; then
		    	if [ ! -f "kafka_2.11-1.1.0.tgz" ]; then
		    		wget http://www-us.apache.org/dist/kafka/1.1.0/kafka_2.11-1.1.0.tgz
		    	fi
		    	tar -xzvf kafka_2.11-1.1.0.tgz

			fi	
		;;
		run) 
			#zkserver
			#$_HOME/kafka_2.11-1.1.0/bin/zookeeper-server-start.sh -daemon $_HOME/kafka_2.11-1.1.0/config/zookeeper.properties
			#server
			$_HOME/kafka_2.11-1.1.0/bin/kafka-server-start.sh -daemon $_HOME/kafka_2.11-1.1.0/config/server.properties
		;;
		stop)
			#_killproc zookeeper
			_killproc kafka
		;;
	esac
}

_kibana(){
	cd $_HOME
	case "$1" in  
		yml)			
			
			sed -i 's/#elasticsearch.username: "user"/elasticsearch.username: "wyy"/' 	$_HOME/kibana-5.3.0/config/kibana.yml
			sed -i 's/#elasticsearch.password: "pass"/elasticsearch.password: "123456"/' 	$_HOME/kibana-5.3.0/config/kibana.yml

			#open $_HOME/kibana-5.3.0/config/kibana.yml
		;;
		setup) 
			wget https://artifacts.elastic.co/downloads/kibana/kibana-5.3.0-darwin-x86_64.tar.gz
			mkdir kibana-5.3.0
			tar -xvzf kibana-5.3.0-darwin-x86_64.tar.gz -C kibana-5.3.0 --strip-components 1
			
		;;
		run)
			#_killproc kibana
		 	#./kibana-5.3.0/bin/kibana
		 	nohup $_HOME/kibana-5.3.0/bin/kibana &
		;;
		stop)
			_killproc kibana	 	
		;;

		install)
			./kibana-5.3.0/bin/kibana-plugin install $2  
		;;
		list)
		   ./kibana-5.3.0/bin/kibana-plugin list
		;;
	esac

}

_nginx(){
	cd $_HOME
	case "$1" in 
		yml)
			echo "yml"
			 
		;;
		conf)
			#open /usr/local/nginx/nginx.conf
		;;
		setup)
			#wget "https://nginx.org/download/nginx-$NGINX_V.tar.gz"
			#mkdir nginx
			#tar -xvzf "nginx-$NGINX_V.tar.gz" -C nginx --strip-components 1

			cd nginx
			# wget https://github.com/madler/zlib/archive/v1.2.1.tar.gz  -O zlib-1.2.1.tar.gz
			# tar -xvzf zlib-1.2.1.tar.gz
			# wget https://ftp.pcre.org/pub/pcre/pcre-8.42.tar.gz
			# tar -xvzf pcre-8.42.tar.gz


			./configure --with-http_ssl_module --with-cc-opt="-I/usr/local/Cellar/pcre/8.42/include -I/usr/local/Cellar/openssl/1.0.2o_2/include/openssl" \
				--with-ld-opt="-L/usr/local/Cellar/pcre/8.42/lib -L/usr/local/Cellar/openssl/1.0.2o_2/lib" \
				--with-pcre=./pcre-8.42 --with-zlib=./zlib-1.2.1 \
				--sbin-path=/usr/local/nginx/nginx \
				--conf-path=/usr/local/nginx/nginx.conf \
				--pid-path=/usr/local/nginx/nginx.pid
			#make & make install
		;;
		run)
			sudo /usr/local/nginx/nginx
		;;
		stop)
			sudo /usr/local/nginx/nginx -s stop
		;;
		restart)
			sudo /usr/local/nginx/nginx -s restart
		;;
	esac
}

###################################################################
##.                   通用区域
###################################################################
_initall(){
	_es setup
	_es yml

	_redis setup
	_redis yml

	_logstash setup
	_logstash yml

	_kibana setup
	_kibana yml

	_kafka setup
	_kafka yml
}





_runall(){
	cd $_HOME
	#_killproc elasticsearch
	#./elasticsearch-5.3.0/bin/elasticsearch -d
	_es run
	
	#_killproc redis
	#./redis-4.0.10/src/redis-server $_HOME/redis-4.0.10/redis.conf
	_redis run


	#_killproc kibana
	#./kibana-5.3.0/bin/kibana
	#nohup $_HOME/kibana-5.3.0/bin/kibana &
	_kibana run

	#_killproc logstash
	#./logstash-5.3.0/bin/logstash  -f $_HOME/mylogstash.conf 
	_logstash run

	_kafka run
}

_killall(){
	_killproc elasticsearch
	_killproc redis
	_killproc logstash
	_killproc kibana

	_killproc zookeeper
	_killproc kafka
}

_state(){

  	psid=$(ps aux | grep elasticsearch | awk '$11!="grep"{print $2}')
  	psid2=$(ps aux | grep logstash | awk '$11!="grep"{print $2}')
	psid3=$(ps aux | grep redis | awk '$11!="grep"{print $2}')
	psid4=$(ps aux | grep kibana | awk '$11!="grep"{print $2}')
	psid5=$(ps aux | grep kafka | awk '$11!="grep"{print $2}')
	psid6=$(ps aux | grep zookeeper | awk '$11!="grep"{print $2}')


	if [[ $1 = "all" ]]; then
	  	psid=$(ps aux | grep elasticsearch | awk '$11!="grep"{print $0}')
	  	psid2=$(ps aux | grep logstash | awk '$11!="grep"{print $0}')
		psid3=$(ps aux | grep redis | awk '$11!="grep"{print $0}')
		psid4=$(ps aux | grep kibana | awk '$11!="grep"{print $0}')
		psid5=$(ps aux | grep kafka | awk '$11!="grep"{print $0}')
		psid6=$(ps aux | grep zookeeper | awk '$11!="grep"{print $0}')
	fi

	echo "------------------------------------Running state------------------------------------"
	echo "elasticsearch:	"$psid
	echo ""
	echo "logstash:	"$psid2
	echo ""
	echo "redis:	"$psid3
	echo ""
	echo "kibana:	"$psid4
	echo ""
	echo "kafka:	"$psid5
	echo ""
	echo "zookeeper:	"$psid6

}



case "$1" in  
	es)        _es $2 $2=3 ;;
    kibana)    _kibana $2 $3;;
    redis)     _redis $2 $3;;
	logstash)  _logstash $2 $3;;
	kafka)     _kafka $2 $3 $4;;
	zookeeper) _zookeeper $2 $3;;
	nginx)     _nginx $2 $3;;

	ktest)     _kafaka_test $2 $3;;  

    init) _initall;;
    state) _state $2;;
	run)   _runall;;
	kill)  _killall;;
	security) _security;;

	conf) _sedfile;;
esac




