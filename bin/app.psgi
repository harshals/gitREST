use lib "lib";
use Dancer;
use Log::Log4perl;
load_app 'NewApp';

use Dancer::Config 'setting';
setting apphandler => 'PSGI';
setting logger => 'PSGI';
Dancer::Config->load;


use Plack::Builder;
my $app = sub {
    my $env = shift;
    my $request = Dancer::Request->new( $env );
    Dancer->dance( $request );
};

builder {

        mount "/debug" => builder {
                enable 'Session', store => 'File';
                enable 'Debug',
                	panels =>[qw/Dancer::Settings Dancer::Logger Parameters Dancer::Version/];
  	      		enable "ConsoleLogger";
                enable "Plack::Middleware::Static",
                   path => qr{^/(images|js|css)/}, root => './public/';
                enable "Plack::Middleware::ServerStatus::Lite",
                   path => '/status',
                   allow => [ '127.0.0.1', '192.168.0.0/16' ],
                   scoreboard => '/tmp';

        $app;
        };
        mount "/" => builder {
  	      		enable "ConsoleLogger";
                $app;
        };
        
        
};


