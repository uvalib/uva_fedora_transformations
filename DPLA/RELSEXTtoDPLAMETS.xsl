<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:uva="http://fedora.lib.virginia.edu/relationships#"
  xmlns:s="http://www.w3.org/2001/sw/DataAccess/rf1/result" exclude-result-prefixes="xs rdf uva s"
  version="2.0">

  <xsl:param name="fedora-url" required="no">http://fedora-prod02.lib.virginia.edu:8080/fedora/</xsl:param>

  <xsl:output encoding="UTF-8" indent="yes" />

  <xsl:template match="/">
    <xsl:variable name="pid">
      <xsl:value-of select="substring(rdf:RDF/rdf:Description/@rdf:about, string-length('info:fedora/') + 1)" />
    </xsl:variable>

    <xsl:variable name="lookupMembers">
      <xsl:value-of select="$fedora-url" />
      <xsl:text>risearch?type=tuples&amp;lang=itql&amp;format=Sparql&amp;query=select%20%24object%20from%20%3C%23ri%3E%20%0Awhere%20%24object%20%3Chttp%3A%2F%2Ffedora.lib.virginia.edu%2Frelationships%23hasCatalogRecordIn%3E%20%3Cinfo%3Afedora%2F</xsl:text>
      <xsl:value-of select="$pid" />
      <xsl:text>%3E%20and%20%24object%20%3Cinfo%3Afedora%2Ffedora-system%3Adef%2Fmodel%23hasModel%3E%20%3Cinfo%3Afedora%2Fuva-lib%3ADPLAItemCModel%3E</xsl:text>
    </xsl:variable>
    <xsl:message>Querying fedora: <xsl:value-of select="$lookupMembers" /></xsl:message>
    <xsl:variable name="sparql" select="document($lookupMembers)" />
    

    <mets:mets xmlns:mets="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="mets http://www.loc.gov/standards/mets/mets.xsd">
      <mets:dmdSec ID="collection-description-mods">
        <mets:mdRef LOCTYPE="PURL" MDTYPE="MODS">
          <xsl:attribute name="xlink:href">http://fedoraproxy.lib.virginia.edu/fedora/objects/<xsl:value-of select="$pid" />/datastreams/descMetadata/content</xsl:attribute>
        </mets:mdRef>
      </mets:dmdSec>
       <xsl:for-each select="$sparql/s:sparql/s:results/s:result/s:object">
        <xsl:variable name="childPid" select="substring(@uri, 13)" />
        <mets:dmdSec>
          <xsl:attribute name="ID" select="concat(translate($childPid, ':', '_'), '-mods')" />
          <mets:mdRef LOCTYPE="PURL" MDTYPE="MODS">
            <xsl:attribute name="xlink:href">http://fedoraproxy.lib.virginia.edu/fedora/objects/<xsl:value-of select="$childPid" />/methods/uva-lib:modsSDef/getMODS</xsl:attribute>
          </mets:mdRef>
        </mets:dmdSec>
      </xsl:for-each>


      <mets:fileSec>
        <xsl:for-each select="$sparql/s:sparql/s:results/s:result/s:object">
          <xsl:variable name="childPid" select="substring(current()/@uri, 13)" />
          <mets:fileGrp USE="preview">
            <xsl:attribute name="ID" select="concat(translate($childPid, ':', '_'), '-files')" />
            <mets:file>
              <xsl:attribute name="ID" select="concat(translate($childPid, ':', '_'), '-preview')" />
              <xsl:attribute name="DMDID" select="concat(translate($childPid, ':', '_'), '-mods')" />
              <mets:FLocat LOCTYPE="PURL">
                <xsl:attribute name="xlink:href">http://fedoraproxy.lib.virginia.edu/fedora/objects/<xsl:value-of select="$pid"/>/methods/djatoka:StaticSDef/getThumbnail</xsl:attribute>
              </mets:FLocat>
            </mets:file>
          </mets:fileGrp>
        </xsl:for-each>
      </mets:fileSec>


      <mets:structMap>
        <mets:div LABEL="Collection">
          <xsl:for-each select="$sparql/s:sparql/s:results/s:result/s:object">
            <xsl:variable name="childPid" select="substring(current()/@uri, 13)" />
              <mets:fptr>
                <xsl:attribute name="FILEID" select="concat(translate($childPid, ':', '_'), '-preview')" />
              </mets:fptr>
          </xsl:for-each>
        </mets:div>
      </mets:structMap>
    </mets:mets>
  </xsl:template>
</xsl:stylesheet>
