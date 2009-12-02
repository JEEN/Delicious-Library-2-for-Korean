package DL2::Schema::ItunesTrack;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("ZITUNESTRACK");
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
  "zprotected",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zcompilation",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zdisccount",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zdiscnumber",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zsize",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zartworkcount",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zrating",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "ztrackid",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zbitrate",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zseason",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "ztotaltime",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zepisodeorder",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "ztracknumber",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zitunesabstractcollection",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zhasvideo",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "ztvshow",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zyear",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zplaycount",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "ztrackcount",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zdateadded",
  {
    data_type => "TIMESTAMP",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zdatemodified",
  {
    data_type => "TIMESTAMP",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zartist",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zpersistentid",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zalbum",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zkind",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zcomposer",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zgenre",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zlocation",
  {
    data_type => "VARCHAR",
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
  "zcomments",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zseries",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "zepisode",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("z_pk");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-12-02 17:45:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mwBhXlbgsigQbY3Kncehnw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
