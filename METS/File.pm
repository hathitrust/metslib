package METS::File;
use strict;
use POSIX qw(strftime);
use Carp qw(croak);
use URI::Escape;
use METS::Subfile;

use XML::LibXML;

# TODO: move to global config
our $mime_map = {
    'zip' => 'application/zip',
    'jpg' => 'image/jpeg',
    'tif' => 'image/tiff',
    'jp2' => 'image/jp2',
    'txt' => 'text/plain',
    'html' => 'text/html',
    'xml' => 'text/xml',
    'pdf' => 'application/pdf',
};

sub new {
    my $class = shift;
    my $filegroup = shift;
    my %attrs = @_;
    return bless {
        attrs => METS::copyAttributes(
            \%attrs, qw(ID SEQ), @METS::FILECORE,
            qw(OWNERID ADMID DMDID GROUPID USE BEGIN END BETYPE)
        ),
        components => [],
        filegroup => $filegroup,
    }, $class;
}

sub set_local_file {
    my $self = shift;
    $self->{'local_file'} = shift;
    $self->{'path'} = (shift or "");
    if($self->{'path'}) { $self->{'path'} .= "/"; }

    $self->compute_md5_checksum()
        if ( not defined $self->{'attrs'}{'CHECKSUM'} );

    if(not defined $self->{'attrs'}{'SIZE'}
        or not defined $self->{'attrs'}{'CREATED'}) {
      my @stat = stat( $self->{'path'} . $self->{'local_file'} )
          or croak("Cannot stat $self->{'local_file'}");
      my $size = $stat[7];
      my $mtime = strftime( "%Y-%m-%dT%H:%M:%SZ", gmtime( $stat[9] ) );
      $self->{'attrs'}{'SIZE'} = $size if not defined $self->{'attrs'}{'SIZE'};

      # By default use the mtime since there's no reliable way to get the
      # creation time
      $self->{'attrs'}{'CREATED'} = $mtime
        if not defined $self->{'attrs'}{'CREATED'};
    }

    $self->{'attrs'}{'MIMETYPE'} = $self->get_mimetype()
      if ( not defined $self->{'attrs'}{'MIMETYPE'} );

}

sub compute_md5_checksum {
    my $self = shift;
    croak("Don't know how to find the file")
        unless defined $self->{'local_file'};
    my $file = $self->{'path'} . $self->{'local_file'};

    require Digest::MD5;
    open( FILE, $file ) or croak "Can't open '$file': $!";
    binmode(FILE);

    my $digest = Digest::MD5->new->addfile(*FILE)->hexdigest;
    close(FILE);
    $self->{'attrs'}{'CHECKSUM'}     = $digest;
    $self->{'attrs'}{'CHECKSUMTYPE'} = 'MD5';

}

sub to_node {
    my $self = shift;

    my $node = METS::createElement( "file", $self->{'attrs'} );

    if ( defined $self->{'local_file'} ) {
        my $flocat = METS::createElement( "FLocat",
          $self->loctype );
        # only escape things that are required to be escaped
        # see http://www.schemacentral.com/sc/xsd/t-xsd_anyURI.html
        #  "URIs require that some characters be escaped with their hexadecimal
        #  Unicode code point preceded by the % character. This includes
        #  non-ASCII characters and some ASCII characters, namely control
        #  characters, spaces, and the following characters (unless they are
        #  used as deliimiters in the URI): <>#%{}|\^`"
        METS::setXLink( $flocat, { href =>
                uri_escape($self->{'local_file'},"\x00-\x1f\x7f-\xff<>#\%{}|\\^`
                    ") } );
        $node->appendChild($flocat);

    }

    foreach my $item ( @{ $self->{'components'} } ) {
        $node->appendChild( $item->to_node() );
    }
    return $node;

}

sub loctype {
  return { LOCTYPE => 'OTHER', OTHERLOCTYPE => 'SYSTEM' };
}

sub get_mimetype {
    my $self = shift;
    my $filename = $self->{'local_file'};
    my ($suffix) = ($filename =~ /\.([^.]+)$/);
    if(defined $suffix and defined $mime_map->{$suffix}) {
	return $mime_map->{$suffix};
    } else {
	return 'application/octet-stream';
    }
}

# Add a file from a DOM element or a METS::File object.
# Additional parameter 'path' gives temporary staging
# path to object.  File isn't expected to actually exist on disk (but it can)
sub add_sub_file {
  my $self = shift;
  my $filename = shift;
  my %attrs = @_;

  $attrs{seq} = $self->{filegroup}->next_seq; 
  $attrs{id} = $self->{filegroup}->assign_id($attrs{prefix}, $filename);

  my $subfile = METS::Subfile->new($filename,%attrs);
  push( @{ $self->{'components'} }, $subfile);
  $subfile->set_local_file($filename);

}

1;
