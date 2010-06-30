package PREMIS::Outcome;

use strict;

my $ns_HT = "http://www.hathitrust.org/premis_extension";
my $ns_prefix_HT = "HT";

sub new {
    my $class = shift;
    my $outcome = shift;
    return bless {
        outcome => $outcome,
	detail => []
    }, $class;
}

sub add_file_list_detail {
    my $self = shift;
    my $fail_message = shift;
    my $fail_type = shift;
    my $file_list = shift;

    my $node = PREMIS::createElement("eventOutcomeDetail");
    $node->appendChild( PREMIS::createElement("eventOutcomeDetailNote", $fail_message));

    my $ext_node = PREMIS::createElement("eventOutcomeDetailExtension");
    my $filelist_node = new XML::LibXML::Element("fileList");
    $filelist_node->setNamespace($ns_HT,$ns_prefix_HT);

    $ext_node->appendChild($filelist_node);

    foreach my $file (@$file_list) {
	my $node = new XML::LibXML::Element("file");
	$node->setNamespace( $ns_HT, $ns_prefix_HT);
	$node->appendText($file);
    }
}

sub to_node {
    my $self = shift;
    my $node = PREMIS::createElement("eventOutcomeInformation");

    $node->appendChild( PREMIS::createElement("eventOutcome",$self->{'outcome'}));

    foreach my $detail (@{$self->{'detail'}}) {
	$node->appendChild($detail);
    }

    return $node;
}

1;
