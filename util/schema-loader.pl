use strict;
use warnings;

use DBIx::Class::Schema::Loader (qw/make_schema_at/);

make_schema_at(
    'DL2::Schema', {
        components => [],
        dump_directory => './lib/DL2/Schema',
    },
    \@ARGV,
    );

__END__

schema-loader.pl dbi:x:x user pass
