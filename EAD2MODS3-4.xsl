<!--
    - An XSLT stylesheet to convert an EAD fragment into a MODS record.  The EAD
    - fragment is expected to contain exactly one EAD, C0X, or C element and 
    - represent a single level in the hierarchy of the collection.
    - 
    - There is no current use for the records generated by this initial version
    - of this transformation.  As such, changes may be made freely without
    - concern for their impact on other systems.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:s="http://www.w3.org/2001/sw/DataAccess/rf1/result"
    xmlns:apia="http://www.fedora.info/definitions/1/0/access/"
    xmlns:mods="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xs s apia mods"
    version="2.0">
    
    <xsl:output byte-order-mark="no" encoding="UTF-8" media-type="text/xml" xml:space="preserve" indent="yes"/>
    
    <xsl:param name="pid" required="yes" />
    <xsl:param name="sourceUrl" required="yes" />
    <xsl:param name="thisUrl" required="yes" />
    <xsl:param name="debug" required="no" />
    
    <xsl:template match="*" priority="-1" mode="primary" />

    <xsl:template match="/">
        <mods:mods xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" version="3.4"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/mods/v3"
            xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd">
            <xsl:comment>
                This MODS record was generated as a transformation from the native form of
                the metadata and may not include all available information.  The original metadata
                may be accessed at <xsl:value-of select="$sourceUrl" />, the transformation 
                used to generate this rendition of the metadata can be viewed at 
                <xsl:value-of select="$thisUrl" />.
            </xsl:comment>

            <xsl:apply-templates select="//*" mode="primary" />

            <!-- TODO: find ancestral records from the repository, read those records and process them to form a more complete MODS record -->
        </mods:mods>                
    </xsl:template>
    
    <xsl:template match="*[name() = 'unittitle']" mode="primary">
        <xsl:variable name="title">
            <xsl:for-each select="current()//text()">
                <xsl:value-of select="current()" />
            </xsl:for-each>
        </xsl:variable>
        <mods:titleInfo>
            <mods:title><xsl:value-of select="normalize-space(current())" /></mods:title>
        </mods:titleInfo>
    </xsl:template>
    
    <xsl:template match="*[name() = 'scopecontent']" mode="primary">
        <xsl:variable name="content">
            <xsl:for-each select="current()//text()">
                <xsl:value-of select="current()" />
            </xsl:for-each>
        </xsl:variable>
        <mods:abstract><xsl:value-of select="$content" /></mods:abstract>
    </xsl:template>
    
    <!-- TODO: add all the other descriptive metadata fields -->
    
</xsl:stylesheet>