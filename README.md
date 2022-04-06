# Example

This assumes we have a sequence of digitized page images with OCR text and MARC metadata:

* `marc.xml` - MARC21 metadata
* `NNNNNNNN.jp2` - JPEG2000 images
* `NNNNNNNN.txt` - OCR plain text
* `NNNNNNNN.xml` - Coordinate OCR

```perl
use METS;
use strict;

my $mets = new METS( objid => "example_objid" );

$mets->add_schema(
    "MARC",
    "http://www.loc.gov/MARC21/slim",
    "http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"
);

my $header = new METS::Header(
    createdate   => "2010-04-30T00:00:00Z",
    recordstatus => "NEW"
);

$header->add_agent(
    role => 'CREATOR',
    type => 'ORGANIZATION',
    name => 'DLPS'
);

$mets->set_header($header);

$dmdSec = new METS::MetadataSection( 'dmdSec', id => "DMD1" );
$dmdSec->set_xml_file(
    "marc.xml",
    mdtype => "MARC",
);

$mets->add_dmd_sec($dmdSec);

my $img_filegroup = new METS::FileGroup( id => 'FG1', use => 'image' );

#$filegroup->set_checksum_cache($checksum_cache);
$img_filegroup->add_files(
    [ glob("*.jp2") ],
    mimetype => 'image/jp2',
    prefix   => 'IMG'
);

$mets->add_filegroup($img_filegroup);

my $ocr_filegroup = new METS::FileGroup( id => 'FG2', use => 'ocr' );

#$filegroup->set_checksum_cache($checksum_cache);
$ocr_filegroup->add_files(
    [ glob("*.txt") ],
    mimetype => 'text/plain',
    prefix   => 'TXT'
);

$mets->add_filegroup($ocr_filegroup);

my $xml_filegroup = new METS::FileGroup( id => 'FG3', use => 'coordOCR' );

#$filegroup->set_checksum_cache($checksum_cache);
$xml_filegroup->add_files(
    [ glob("0*.xml") ],
    mimetype => 'text/xml',
    prefix   => 'XML'
);
$mets->add_filegroup($xml_filegroup);

my $struct_map = new METS::StructMap;
my $voldiv = new METS::StructMap::Div( type => 'volume' );
$struct_map->add_div($voldiv);
for ( my $i = 1; $i <= 10; $i++ ) {
    my $imgnum = sprintf( "%08d", $i );
    my $pagediv = $voldiv->add_file_div(
        [   $img_filegroup->get_file_id("$imgnum.jp2"),
            $ocr_filegroup->get_file_id("$imgnum.txt"),
            $xml_filegroup->get_file_id("$imgnum.xml")
        ],
        order => $i,
        type  => "page",
    );
}

$mets->add_struct_map($struct_map);

print $mets->to_node()->toString(1);
```
