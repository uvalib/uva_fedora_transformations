<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:s="http://www.w3.org/2001/sw/DataAccess/rf1/result"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:uva-rels="http://fedora.lib.virginia.edu/relationships#"
  xmlns="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xs rdf uva-rels"
  version="2.0">
  
  <xsl:param name="pid" required="yes" />
  <xsl:param name="fedora-url" required="no">http://fedora-prod02.lib.virginia.edu:8080/fedora/</xsl:param>
  
  <xsl:output encoding="UTF-8" indent="yes" />
  
  <xsl:template match="/">
    <xsl:for-each select="*">
      <xsl:apply-templates mode="duplicate" select="current()"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="mods:location[1]" mode="duplicate">
    <xsl:variable name="exemplar">
      <xsl:call-template name="lookupDigitizedExemplar">
        <xsl:with-param name="itemPid" select="$pid" />
      </xsl:call-template>
    </xsl:variable>
    <location>
      <xsl:if test="not($exemplar='')">
          <url access="object in context">http://search.lib.virginia.edu/catalog/<xsl:value-of select="substring($exemplar, 13)"/></url>
          <url access="preview">http://fedoraproxy.lib.virginia.edu/fedora/objects/<xsl:value-of select="substring($exemplar, 13)"/>/methods/djatoka:StaticSDef/getThumbnail</url>
          <url access="raw object">http://fedoraproxy.lib.virginia.edu/fedora/objects/<xsl:value-of select="substring($exemplar, 13)"/>/methods/djatoka:StaticSDef/getStaticImage</url>
      </xsl:if>
      <xsl:for-each select="current()/*">
        <xsl:apply-templates mode="duplicate" select="current()" />
      </xsl:for-each>
    </location>
  </xsl:template>
  
  <xsl:template match="@*|node()" mode="duplicate">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="duplicate"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Performs a fedora resource index query that will return the object uri of the 
    exemplar (digital representation) of the provided item if a digitized version
    exists for that item.
  -->
  <xsl:template name="lookupDigitizedExemplar">
    <xsl:param name="itemPid" required="yes" />
    <xsl:variable name="lookupExemplars">
      <xsl:value-of select="$fedora-url" /><xsl:text>risearch?type=tuples&amp;lang=itql&amp;format=Sparql&amp;query=select%20%24exemplar%20from%20%3C%23ri%3E%20where%20%3Cinfo%3Afedora%2F</xsl:text>
      <xsl:value-of select="$itemPid" />
      <xsl:text>%3E%20%3Chttp%3A%2F%2Ffedora.lib.virginia.edu%2Frelationships%23hasExemplar%3E%20%24exemplar</xsl:text>
    </xsl:variable>
    <xsl:message><xsl:value-of select="$lookupExemplars" /></xsl:message>
    <xsl:value-of select="document($lookupExemplars)/s:sparql/s:results/s:result/s:exemplar/@uri" />
  </xsl:template>
  
</xsl:stylesheet>