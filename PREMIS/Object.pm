package PREMIS::Object;
use strict;
use PREMIS;

use XML::LibXML;

my $ns_xsi = "http://www.w3.org/2001/XMLSchema-instance";
sub new {
    my $class = shift;
    my $idtype = shift;
    my $id    = shift;
    return bless {
	idtype	   => $idtype,
        id         => $id,
        properties => []
    }, $class;
}

# Adds a PREMIS "sigificantProperties" element with the given type and value.
sub add_significant_property {
    my $self  = shift;
    my $type  = shift;
    my $value = shift;

    my $prop_node = PREMIS::createElement("significantProperties");
    my $type_node
        = PREMIS::createElement( "significantPropertiesType", undef, $type );
    my $value_node
        = PREMIS::createElement( "significantPropertiesValue", undef, $value );
    $prop_node->appendChild($type_node);
    $prop_node->appendChild($value_node);

    push( @{ $self->{properties} }, $prop_node );
}

# Sets the preservation level to be output in the preservationLevel element
sub set_preservation_level {
    my $self               = shift;
    my $preservation_level = shift;

    $self->{'preservation_level'} = $preservation_level;
}

sub to_node {
    my $self = shift;

    my $node = PREMIS::createElement("object");
    $node->setAttributeNS($ns_xsi,"xsi:type","PREMIS:representation");
    if ( defined $self->{'id'} ) {
        my $identifier = PREMIS::createElement("objectIdentifier");
        $identifier->appendChild(
            PREMIS::createElement( "objectIdentifierType", $self->{'idtype'} ) );
        $identifier->appendChild(
            PREMIS::createElement( "objectIdentifierValue", $self->{'id'} ) );
        $node->appendChild($identifier);
    }

    if ( defined $self->{'preservation_level'} ) {
        my $presLevel = PREMIS::createElement("preservationLevel");
        $presLevel->appendChild(
            PREMIS::createElement("preservationLevelValue","1") );
        $node->appendChild($presLevel);
    }

    foreach my $property ( @{ $self->{'properties'} } ) {
        $node->appendChild($property);
    }

    return $node;
}

1;
