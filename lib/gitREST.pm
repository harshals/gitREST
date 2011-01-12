package gitREST;
use Dancer ':syntax';
our $VERSION = '0.1';

set serializer => 'JSON';


get '/' => sub {
    template 'index';
};

## index method, simply list 

before sub {
	
	my $count = session("counter");
    session "counter" => ++$count;
	
	debug "before path is " . request->path;
};

post '/update/:repos' => sub {

    my $p = request->params;
	
	if ($p->{'repos'} eq 'adhril') {
		
		my $path = config->{repositories}->{$p->{'repos'}}->{'path'};
		my $log = config->{gitlog};
		
		my $output = `/bin/sh -c 'cd $path && git pull -q origin master' >> $log`;

		return { output => $output };		

	}else{
		
		send_error(  "server not found" );
	}
	
};

true;
