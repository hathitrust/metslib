package METS::StructMap;

sub new {
    my $class = shift;
    my $id = shift;
    my $type = shift;
    my $label = shift;

    return bless {}, $class;
}

package METS::StructMap::Div;

sub new {
}

sub add_mptr {
    my $self = shift;
    my $id = shift;
    my $xlink = shift; #from METS::XLink
    my $contentids = shift;
}

sub add_fptr {
    my $self = shift;
    my $id = shift;
    my $fileid = shift;
    my $contentids = shift;

    # Either a METS::StructMap::Area or a METS::StructMap::AreaAggregation
    my $area = shift;

}

sub add_div {
    my $self = shift;
    my $div = shift;
}

package METS::StructMap::AreaAggregation;

sub new {
    my $class = shift;
    my $aggtype = shift; #either seq or par
}

sub add_area {
    # adds either an area or an area aggregation to this
    # aggregate.
    my $self = shift;
    my $area = shift;
}

package METS::StructMap::Area;

# attrs can be id, fileid, shape, coords, begin, end, betype, extent, exttype,
# admid, contentids

sub new {
    my $class = shift;
    my $attrs = shift;
}
