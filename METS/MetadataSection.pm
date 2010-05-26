#!/usr/bin/perl

package METS::MetadataSection;
use strict;

use XML::LibXML;

# Creates a new metadata section. element_name is dmdSec, techMD, rightsMD,
# sourceMD, or digiprovMD.

sub new {
    my $class        = shift;
    my $element_name = shift;
    my %attrs        = @_;
    return bless {
        attrs => METS::copyAttributes(
            \%attrs, qw(ID GROUPID ADMID CREATED STATUS)
        ),
        element_name => $element_name
    }, $class;
}

# Point to external metadata
sub set_md_ref {

    my $self  = shift;
    my %attrs = @_;

    METS::checkAttrVal( $attrs{'loctype'}, @METS::allowed_LOCTYPE );
    METS::checkAttrVal( $attrs{'mdtype'},  @METS::allowed_MDTYPE );

    $self->{'mdref'} = METS::createElement(
        "mdRef",
        METS::copyAttributes(
            \%attrs,         'ID',
            @METS::LOCATION, @METS::METADATA,
            @METS::FILECORE, 'LABEL',
            'XPTR'
        )
    );

    METS::setXLink( $self->{'mdref'}, $attrs{'xlink'} )
        if defined( $attrs{'xlink'} );

}

# Embed data in the metadata section
sub set_data {
    my $self  = shift;
    my $data  = shift;
    my %attrs = @_;

    METS::checkAttrVal( $attrs{'mdtype'}, @METS::allowed_MDTYPE );

    $self->{'mdwrap'} = METS::createElement(
        "mdWrap",
        METS::copyAttributes(
            \%attrs, 'ID', @METS::METADATA, @METS::FILECORE, 'LABEL'
        )
    );

    if ( ref($data) ) {

        # had better be an XML node ..
        my $xmlDataNode = METS::createElement("xmlData");
        $self->{'mdwrap'}->appendChild($xmlDataNode);
        $xmlDataNode->appendChild($data);
    }
    else {

        # Data had better already be encoded, e.g. not contain any multibyte
        # characters
        require MIME::Base64;
        my $encoded_data = encode_base64($data);
        my $binDataNode
            = METS::createElement( "binData", undef, $encoded_data );
    }

}

sub set_xml_file {
    my $self    = shift;
    my $xmlfile = shift;

    # parse xml file
    my $parsed_xml = XML::LibXML->load_xml( location => $xmlfile );
    $self->set_xml_node($parsed_xml->documentElement(),@_);
}

sub set_xml_string {
    my $self = shift;
    my $xmlstring = shift;
    my $parsed_xml = XML::LibXML->load_xml( string => $xmlstring );
    $self->set_xml_node($parsed_xml->documentElement(),@_);

}

sub set_xml_node {

    my $self = shift;
    my $node = shift;
    
    $self->set_data(
	$node,
	mimetype => "text/xml",
	@_
    );
}

sub to_node {
    my $self = shift;
    my $node
        = METS::createElement( $self->{'element_name'}, $self->{'attrs'} );

    $node->appendChild( $self->{'mdref'} )  if defined $self->{'mdref'};
    $node->appendChild( $self->{'mdwrap'} ) if defined $self->{'mdwrap'};

    return $node;
}

1;
