use lib "lib";
use Dancer;
load_app 'gitREST';

use Dancer::Config 'setting';
setting apphandler => 'PSGI';
setting logger => 'PSGI';
setting session => 'PSGI';
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
                	panels =>[qw/Memory Response Timer Environment Dancer::Settings Dancer::Logger Parameters Dancer::Version Session DBIC::QueryLog/];
 #       enable "ConsoleLogger";
                enable "Plack::Middleware::Static",
                   path => qr{^/(images|js|css)/}, root => './public/';
                enable "Plack::Middleware::ServerStatus::Lite",
                   path => '/status',
                   allow => [ '127.0.0.1', '192.168.0.0/16' ],
                   scoreboard => '/tmp';

        $app;
        };
        mount "/" => builder {
                $app;
        };
        
        
};


