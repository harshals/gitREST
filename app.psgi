use Dancer;
load_app 'gitREST';

set session => 'simple';

set logger => 'PSGI';

set serializer => 'JSON';

set apphandler => 'PSGI';

use Plack::Builder;

my $app = sub {
    my $env = shift;
    my $request = Dancer::Request->new( $env );
    Dancer->dance( $request );
};

builder {

        mount "/" => builder {
                $app;
        };
        
        
};


