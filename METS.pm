package METS;
use strict;

use XML::LibXML;
use METS::Header;
use METS::MetadataSection;
use METS::File;
use METS::FileGroup;
use METS::StructMap;
use METS::ChecksumCache;

my $ns_METS        = "http://www.loc.gov/METS/";
my $ns_prefix_METS = "METS";
my $schema_METS    = "http://www.loc.gov/standards/mets/mets.xsd";
my $ns_prefix_xlink = "xlink";
my $ns_xlink       = "http://www.w3.org/1999/xlink";
my $ns_prefix_xsi = "xsi";
my $ns_xsi         = "http://www.w3.org/2001/XMLSchema-instance";
our @LOCATION = ( 'LOCTYPE',  'OTHERLOCTYPE' );
our @METADATA = ( 'MDTYPE',   'OTHERMDTYPE', 'MDTYPEVERSION' );
our @FILECORE = ( 'MIMETYPE', 'SIZE', 'CREATED', 'CHECKSUM', 'CHECKSUMTYPE' );

our @allowed_AGENT_TYPE = qw(INDIVIDUAL ORGANIZATION);
our @allowed_AGENT_ROLE
    = qw(CREATOR EDITOR ARCHIVIST PRESERVATION DISSEMINATOR
    CUSTODIAN IPOWNER);

our @allowed_LOCTYPE = qw(ARK URN URL PURL HANDLE DOI OTHER);
our @allowed_MDTYPE
    = qw(MARC MODS EAD DC NISOIMG LC-AV VRA TEIHDR DDI FGDC LOM PREMIS PREMIS:OBJECT PREMIS:AGENT PREMIS:RIGHTS PREMIS:EVENT TEXTMD METSRIGHTS ISO 19115:2003 NAP OTHER);

sub new {
    my $class = shift;
    my %attrs = @_;
    my $doc   = new XML::LibXML::Document;
    return bless {
        doc     => $doc,
        attrs   => copyAttributes( \%attrs, qw(ID OBJID LABEL TYPE PROFILE) ),
        schemas => [],
        filegroups => [],
        structmaps => []
    }, $class;
}

# Add a schema to the list of schemas for this document.
sub add_schema {
    my $self   = shift;
    my $prefix = shift;
    my $ns     = shift;
    my $schema = shift;
    push( @{ $self->{'schemas'} }, [ $prefix, $ns, $schema ] );

}

# Return the root node of the DOM for the METS document
sub to_node {
    my $self = shift;

    my $doc = $self->{'doc'};
    my $mets_node = createElement( "mets", $self->{'attrs'} );

    my @schemaLocations = ("$ns_METS $schema_METS");
    foreach my $schema ( @{ $self->{'schemas'} } ) {
        my ( $prefix, $ns, $schema ) = @$schema;

        # Add the namespace but don't change the namespace of the node
        $mets_node->setNamespace( $ns, $prefix, 0 );

        push( @schemaLocations, "$ns $schema" ) if defined $schema;
    }
    # set utility namespaces that don't have associated schemata
    $mets_node->setNamespace($ns_xlink,$ns_prefix_xlink,0);
    $mets_node->setNamespace($ns_xsi,$ns_prefix_xsi,0);

    $mets_node->setAttributeNS( $ns_xsi, "xsi:schemaLocation",
        join( " ", @schemaLocations ) )
        if (@schemaLocations);
    $doc->setDocumentElement($mets_node);

    $mets_node->appendChild( objectOrNodeToNode( $self->{'header'} ) )
        if defined $self->{'header'};

    foreach my $dmdsec ( @{ $self->{'dmdsecs'} } ) {
        $mets_node->appendChild( objectOrNodeToNode($dmdsec) );
    }

    foreach my $amdsec ( @{ $self->{'amdsecs'} } ) {
        my $amdsec_node
            = createElement( "amdSec", { ID => $amdsec->{'id'} } );
        $mets_node->appendChild($amdsec_node);
        my $mdsecs = $amdsec->{'sections'};
        foreach my $mdsec (@$mdsecs) {
            $amdsec_node->appendChild( objectOrNodeToNode($mdsec) );
        }
    }

    if ( @{ $self->{'filegroups'} } ) {
        my $filesec_node = createElement("fileSec");
        $mets_node->appendChild($filesec_node);
        foreach my $filegroup ( @{ $self->{'filegroups'} } ) {
            $filesec_node->appendChild( objectOrNodeToNode($filegroup) );
        }
    }

    if ( @{ $self->{'structmaps'} } ) {
        foreach my $structmap ( @{ $self->{'structmaps'} } ) {
            $mets_node->appendChild( objectOrNodeToNode($structmap) );
        }
    }

    return $doc;

}

# Get the METS::Header object associated with this METS document
sub set_header {
    my $self = shift;
    $self->{'header'} = shift;
}

# Add a dmdSec from a DOM element or METS::MetadataSection object
sub add_dmd_sec {
    my $self    = shift;
    my $section = shift;

    push( @{ $self->{dmdsecs} }, $section );
}

# Add an amdSec from DOM elements or METS::MetadataSection objects.
# id is optional, used for the ID attribute on the amdSec element
sub add_amd_sec {
    my $self = shift;
    my $id   = shift;
    push( @{ $self->{amdsecs} }, { id => $id, sections => \@_ } );
}

# Add a file group from a DOM element or a METS::FileGroup object.
sub add_file_group {
    my $self      = shift;
    my $id        = shift;
    my $filegroup = shift;

}

# Add a structMap from a DOM element or a METS::StructMap object
sub add_struct_map {
    my $self      = shift;
    my $structmap = shift;

    push( @{ $self->{'structmaps'} }, $structmap );
}

# Creates the element in the METS namespace with the given attributes,
# and text, if the attribute values are defined.
sub createElement {
    my $name       = shift;
    my $attributes = shift;
    my $text       = shift;

    my $node = new XML::LibXML::Element($name);
    $node->setNamespace( $ns_METS, $ns_prefix_METS );
    if ( defined $attributes and ref($attributes) eq 'HASH' ) {
        while ( my ( $attr, $val ) = each %$attributes ) {
            $node->setAttribute( $attr, $val ) if defined $val;
        }
    }

    if ( defined $text and !ref($text) ) {
        $node->appendText($text);
    }
    return $node;
}

# Copies allowed attributes to output hash; input attribute names
# should be normalized to lower case.

sub copyAttributes {
    my $attrs_in   = shift;
    my @attr_names = @_;
    my $attrs_out  = {};

    foreach my $attr_name (@attr_names) {
        $attrs_out->{$attr_name} = $attrs_in->{ lc($attr_name) };
    }

    return $attrs_out;
}

# Throw an error unless the given attribute value is either not defined or is
# in the list of allowed values.

sub checkAttrVal {
    my $attr         = shift;
    my @allowed_vals = @_;

    return 1 if not defined $attr;

    foreach my $allowed (@allowed_vals) {
        if ( $allowed eq $attr ) {
            return 1;
        }
    }

    die("Unexpected attribute value $attr");
}

sub setXLink {
    my $element     = shift;
    my $xlink_attrs = shift;

    while ( my ( $attr, $val ) = each %$xlink_attrs ) {
        if ( $attr eq 'type' ) {
            $element->setAttribute( $attr, $val );
        }
        else {
            $element->setAttributeNS( $ns_xlink, "xlink:$attr", $val );
        }
    }
}

sub objectOrNodeToNode {
    my $thing = shift;

    if ( ref($thing) =~ /^XML::LibXML/ ) {
        return $thing;
    }
    else {
        return $thing->to_node();
    }
}

sub add_filegroup {
    my $self      = shift;
    my $filegroup = shift;
    push( @{ $self->{'filegroups'} }, $filegroup );
}
