package METS::StructMap;

use strict;

sub new {
    my $class = shift;
    my %attrs = @_;

    return bless {
        components => [],
        attrs      => METS::copyAttributes( \%attrs, qw(ID TYPE LABEL) ),
    }, $class;
}

sub add_file_div {
    my $self    = shift;
    my $fileids = shift;
    my %attrs   = @_;
    my $div     = METS::StructMap::Div->new(%attrs);
    foreach my $fileid ( @{$fileids} ) {
        $div->add_fptr( fileid => $fileid );
    }
    $self->add_div($div);

}

sub to_node {
    my $self     = shift;
    my $nodename = shift;
    $nodename = "structMap" if not defined $nodename;
    my $node = METS::createElement( $nodename, $self->{'attrs'} );

    foreach my $component ( @{ $self->{'components'} } ) {
        $node->appendChild( METS::objectOrNodeToNode($component) );
    }
    return $node;
}

sub add_div {
    my $self = shift;
    my $div  = shift;
    push( @{ $self->{'components'} }, $div );
}

package METS::StructMap::Div;

our @ISA = qw(METS::StructMap);

use strict;

sub new {
    my $class = shift;
    my %attrs = @_;

    return bless {
        components => [],
        attrs      => METS::copyAttributes(
            \%attrs, qw(ID ORDER ORDERLABEL LABEL DMDID ADMID TYPE CONTENTIDS)
        ),
    }, $class;
}

sub add_fptr {
    my $self  = shift;
    my %attrs = @_;
    my $fptr  = METS::createElement( "fptr",
        METS::copyAttributes( \%attrs, qw(ID FILEID CONTENTIDS) ) );

    push( @{ $self->{'components'} }, $fptr );

}

sub to_node {
    my $self = shift;
    return $self->SUPER::to_node("div");
}

1;
