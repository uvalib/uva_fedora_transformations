<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:s="http://www.w3.org/2001/sw/DataAccess/rf1/result"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:uva-rels="http://fedora.lib.virginia.edu/relationships#"
  xmlns:fedora-model="info:fedora/fedora-system:def/model#"
  xmlns="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xs rdf uva-rels s fedora-model"
  version="2.0">
  
  <xsl:param name="pid" required="yes" />
  <xsl:param name="exemplarPid" required="yes" />
  <xsl:param name="virgo-url">http://search.lib.virginia.edu/catalog/</xsl:param>
  <xsl:param name="iiif-url">http://iiif.lib.virginia.edu/iiif/</xsl:param>
  <xsl:param name="iiif-manifest-url">http://tracksys.lib.virginia.edu:8080/"</xsl:param>
  <xsl:param name="rights-wrapper-url">http://rightswrapper2.lib.virginia.edu:8090/rights-wrapper/</xsl:param>
  
  
  <xsl:output encoding="UTF-8" indent="yes" />
  
  <xsl:template match="/">
    <xsl:for-each select="*">
      <xsl:apply-templates mode="duplicate" select="current()"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="mods:location[1]" mode="duplicate">
    <location>
      <url access="object in context">http://search.lib.virginia.edu/catalog/<xsl:value-of select="$pid"/></url>
      <url access="preview"><xsl:value-of select="$iiif-url" /><xsl:value-of select="$exemplarPid"/>/[pid]/full/!125,125/0/default.jpg</url>
      <url access="iiif-presentation-manifest"><xsl:value-of select="$iiif-manifest-url" /><xsl:value-of select="$pid"/>/manifest.json</url>
      <url access="raw object"><xsl:value-of select="$rights-wrapper-url" />?pid=<xsl:value-of select="$pid" />&amp;pagePid=<xsl:value-of select="$exemplarPid"/></url>
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
  
</xsl:stylesheet>
