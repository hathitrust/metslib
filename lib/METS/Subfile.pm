package METS::Subfile;
use strict;
use METS::File;

use base qw(METS::File);

sub compute_md5_checksum {
  # don't compute
}

sub loctype { 
  return { LOCTYPE => 'URL' };
}

sub set_local_file {
  my $self = shift;
  $self->{'local_file'} = shift;
}

1;
