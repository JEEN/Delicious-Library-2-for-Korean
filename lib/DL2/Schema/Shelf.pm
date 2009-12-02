package DL2::Schema::Shelf;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("ZSHELF");
__PACKAGE__->add_columns(
  "z_ent",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "z_pk",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "z_opt",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zrootshelf",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "z29_rootshelf",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zshouldattempttoloadsharedlibrary",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zlastmodificationdate",
  {
    data_type => "TIMESTAMP",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zname",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zuuidstring",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zforeignuuidstring",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zaddressbookuniqueidstring",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zpredicatestring",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zmediatype",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zlastname",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zfirstname",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zorganization",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zsharedlibraryurl",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zarchivedmediasortdescriptors",
  {
    data_type => "BLOB",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zarchivedmediumtablecolumns",
  {
    data_type => "BLOB",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("z_pk");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-12-02 17:45:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5/BYbdcbzbqDVpvmdDr0KA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
