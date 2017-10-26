<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:s="http://www.w3.org/2001/sw/DataAccess/rf1/result"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:uva-rels="http://fedora.lib.virginia.edu/relationships#"
  xmlns:fedora-model="info:fedora/fedora-system:def/model#"
  xmlns:date="java:java.util.Date"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
  xmlns="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="mods date fn ss #default rdf uva-rels s fedora-model"
  version="2.0">

  <xsl:param name="pid" required="yes" />

  <xsl:param name="exemplarPid" required="yes" />

  <!-- the rights statment uri.  If specified, it will override an existing "use and reproduction" accessCondition. --> 
  <xsl:param name="rights-uri" />

  <xsl:param name="virgo-url">http://search.lib.virginia.edu/catalog/</xsl:param>

  <xsl:param name="iiif-url">http://iiif.lib.virginia.edu/iiif/</xsl:param>

  <xsl:param name="rights-wrapper-url">http://rightswrapper2.lib.virginia.edu:8090/rights-wrapper</xsl:param>

  <xsl:output encoding="UTF-8" indent="yes" />
  
  <xsl:template match="/">
    <xsl:for-each select="*">
      <xsl:apply-templates mode="duplicate" select="current()"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:mods" mode="duplicate">
    <mods>
      <xsl:copy-of select="@*" />
      <xsl:if test="$rights-uri">
        <accessCondition type="use and reproduction"><xsl:value-of select="$rights-uri"/></accessCondition>
      </xsl:if>
      <xsl:for-each select="*">
        <xsl:apply-templates mode="duplicate" select="current()"/>
      </xsl:for-each>
      <xsl:if test="not(/mods:mods/mods:location)">
        <location>
          <xsl:if test="not(mods:url[@usage='primary'])">
            <url access="object in context" usage="primary"><xsl:value-of select="$virgo-url" /><xsl:value-of select="$pid"/></url>
          </xsl:if>
          <url access="preview"><xsl:value-of select="$iiif-url" /><xsl:value-of select="$exemplarPid"/>/full/!300,300/0/default.jpg</url>
          <url access="iiif-presentation-manifest"><xsl:value-of select="$virgo-url" /><xsl:value-of select="$pid"/>/iiif/manifest.json</url>
          <url access="raw object"><xsl:value-of select="$rights-wrapper-url" />?pid=<xsl:value-of select="$pid" />&amp;pagePid=<xsl:value-of select="$exemplarPid"/></url>
        </location>
      </xsl:if>
      <note type="ownership">University of Virginia Library</note>
    </mods>
  </xsl:template>
  
  <xsl:template match="mods:accessCondition[@type='use and reproduction' and $rights-uri]" mode="duplicate" />

  <xsl:template match="mods:dateIssued[1]" mode="duplicate">
    <xsl:copy-of select="current()" /> 
    <xsl:if test="not(//mods:dateCreated[@keyDate='yes'])">
      <dateCreated keyDate="yes">
        <xsl:value-of select="text()"/>
      </dateCreated>
    </xsl:if>
    
  </xsl:template>

  <xsl:template match="mods:location[1]" mode="duplicate">
    <location>
      <xsl:for-each select="current()/*">
        <xsl:apply-templates mode="duplicate" select="current()" />
      </xsl:for-each>
      <xsl:if test="not(mods:url[@usage='primary'])">
        <url access="object in context" usage="primary"><xsl:value-of select="$virgo-url" /><xsl:value-of select="$pid"/></url>
      </xsl:if>
      <url access="preview"><xsl:value-of select="$iiif-url" /><xsl:value-of select="$exemplarPid"/>/full/!200,200/0/default.jpg</url>
      <url access="iiif-presentation-manifest"><xsl:value-of select="$virgo-url" /><xsl:value-of select="$pid"/>/iiif/manifest.json</url>
      <url access="raw object"><xsl:value-of select="$rights-wrapper-url" />?pid=<xsl:value-of select="$pid" />&amp;pagePid=<xsl:value-of select="$exemplarPid"/></url>
    </location>
  </xsl:template>

  <xsl:template match="*[namespace-uri()='http://www.loc.gov/mods/v3']" mode="duplicate" priority="-1">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@* | node()" mode="duplicate" />
    </xsl:element>
  </xsl:template>
  <xsl:template match="*" mode="duplicate" priority="-2">
    <xsl:element name="{name()}">
      <xsl:apply-templates select="@* | node()" mode="duplicate"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@*|node()" mode="duplicate" priority="-3">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="duplicate"/>
    </xsl:copy>
  </xsl:template>
    
</xsl:stylesheet>
