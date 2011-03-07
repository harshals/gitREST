package gitREST;
use Dancer ':syntax';
our $VERSION = '0.1';


## index method, simply list 

before sub {
	
	my $count = session("counter");
    session "counter" => ++$count;
	
};

get '/config' => sub {
	
	use Data::Dumper;
	content_type 'text/html';
	return Dumper(config);
};

get '/server/:command/:repos' => sub {
	
    my $p = request->params;

	my $path = config->{repositories}->{$p->{'repos'}}->{'path'}; 
	my $type = config->{repositories}->{$p->{'repos'}}->{'type'}; 
	my $name = config->{repositories}->{$p->{'repos'}}->{'name'}; 
	my $command = $p->{'command'};

	my $log = config->{gitlog};

	unless ($command =~ m/(start|stop|restart)$/) {
		
		return ({ error => "$command action not recognized" });
	}

	if ( -d $path &&  $type eq 'fcgi') {
		
		my $output  = `/bin/sh -c 'cd $path && servers.pl restart $name ' >>$log`;

		return { output => $output };
	}elsif ( -d $path &&  $type eq 'psgi') {
		
		my $output;
		my $pidfile = config->{repositories}->{$p->{'repos'}}->{'pidfile'}; 
		my $starman = `which starman`; #'/usr/local/bin/starman';
		chomp $starman;
		my $workers = config->{repositories}->{$p->{'repos'}}->{'workers'} || 1; 
		my $ssd = `which start-stop-daemon`;
		chomp $ssd;

		if ($command eq 'stop') {
			
			if (-f $pidfile) {

				$output  = `/bin/sh -c 'cd $path && $ssd --stop --pidfile $pidfile' >> $log`;
			}else {
				
				return ( { error => "$pidfile does not exists"});
			}


		}elsif ($command eq 'start') {

			unless (-f $pidfile) {

				$output  = `/bin/sh -c 'cd $path &&  $starman --workers $workers --daemonize --pid $pidfile app.psgi' >> $log`;
			}else {

				return ( { error => "$pidfile already exists"});
			}
		
		}else {

			$output  = `/bin/sh -c 'cd $path && /sbin/start-stop-daemon --stop --pidfile $pidfile' >> $log`;
			$output  .= `/bin/sh -c 'cd $path &&  $starman --workers $workers --daemonize --pid $pidfile app.psgi' >> $log`;
		}
		
		return { output => $output };
	}else{
		
		return ( {error =>  "server not found with $type and $path"  });
	}
};

post '/update/:repos/:branch' => sub {

    my $p = request->params;
	
	my $path = config->{repositories}->{$p->{'repos'}}->{'path'}; 
	my $branch = $p->{'branch'} || 'master';
	my $log = config->{gitlog};


	if ( -d $path  ) {
		
		my $output = `/bin/sh -c 'cd $path && git pull -q origin $branch' >> $log`;

		return { output => $output };		

	}else{
		
		return ( {error =>  "server not found" });
	}
	
};

true;
