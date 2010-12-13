package METS::File;
use strict;
use POSIX qw(strftime);
use Carp qw(croak);

use XML::LibXML;

# TODO: move to global config
our $mime_map = {
    'zip' => 'application/zip',
    'jpg' => 'image/jpeg',
    'tif' => 'image/tiff',
    'jp2' => 'image/jp2',
    'txt' => 'text/plain',
    'html' => 'text/html',
    'xml' => 'text/xml'
};

sub new {
    my $class = shift;
    my %attrs = @_;
    return bless {
        attrs => METS::copyAttributes(
            \%attrs, qw(ID SEQ), @METS::FILECORE,
            qw(OWNERID ADMID DMDID GROUPID USE BEGIN END BETYPE)
        )
    }, $class;
    subfiles => [];
}

sub set_local_file {
    my $self = shift;
    $self->{'local_file'} = shift;

    $self->compute_md5_checksum()
        if ( not defined $self->{'attrs'}{'CHECKSUM'} );

    my @stat = stat( $self->{'local_file'} )
        or croak("Cannot stat $self->{'local_file'}");
    my $size = $stat[7];
    my $mtime = strftime( "%Y-%m-%dT%H:%M:%S", localtime( $stat[9] ) );
    $self->{'attrs'}{'SIZE'} = $size if not defined $self->{'attrs'}{'SIZE'};

    # By default use the mtime since there's no reliable way to get the
    # creation time
    $self->{'attrs'}{'CREATED'} = $mtime
        if not defined $self->{'attrs'}{'CREATED'};

    $self->{'attrs'}{'MIMETYPE'} = $self->get_mimetype()
	if ( not defined $self->{'attrs'}{'MIMETYPE'} );

}

sub compute_md5_checksum {
    my $self = shift;
    croak("Don't know how to find the file")
        unless defined $self->{'local_file'};
    my $file = $self->{'local_file'};

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
            { LOCTYPE => 'OTHER', OTHERLOCTYPE => 'SYSTEM' } );
        METS::setXLink( $flocat, { href => $self->{'local_file'} } );
        $node->appendChild($flocat);

    }
    return $node;

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

1;
