package gitREST;
use Dancer ':syntax';
our $VERSION = '0.1';


## index method, simply list 

before sub {
	
	my $count = session("counter");
    session "counter" => ++$count;
	
};

get '/restart/:repos' => sub {
	
    my $p = request->params;

	my $path = config->{repositories}->{$p->{'repos'}}->{'path'}; 

	my $log = config->{gitlog};

	if ( -f  $path ) {
		
		my $output  = `/bin/sh -c 'cd $path && servers.pl restart git.server' >>$log`;

		return { output => $outptu };
	}else{
		
		return ( {error =>  "server not found" });
	}
}

post '/update/:repos/:branch' => sub {

    my $p = request->params;
	
	if ( -f  config->{repositories}->{$p->{'repos'}}->{'path'}) {
		
		my $path = config->{repositories}->{$p->{'repos'}}->{'path'};
		my $log = config->{gitlog};
		
		my $output = `/bin/sh -c 'cd $path && git pull -q origin master' >> $log`;

		return { output => $output };		

	}else{
		
		return ( {error =>  "server not found" });
	}
	
};

true;
