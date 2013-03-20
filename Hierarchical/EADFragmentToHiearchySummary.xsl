<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:s="http://www.w3.org/2001/sw/DataAccess/rf1/result"
    exclude-result-prefixes="xs s"
    version="2.0">
    
    <xsl:output byte-order-mark="no" encoding="UTF-8" media-type="text/xml" xml:space="default" indent="yes"/>
    
    <xsl:param name="fedora-host">localhost</xsl:param>
    <xsl:param name="pid" required="yes" />
    <xsl:param name="debug" />
    <xsl:param name="component_max">3</xsl:param>
    
    <xsl:template match="/">
        <xsl:for-each select="*">
            <xsl:apply-templates select="current()" />
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="*" />
    
    <xsl:template match="ead">
        <!-- Check for cached hierarchy first, since this is the collection root and therefore 
        possibly very big -->
        <xsl:variable name="summary" select="document(concat('http://', $fedora-host, ':8080/fedora/objects/', $pid, '/datastreams/hierarchy-brief-cached/content'))" />
        <xsl:choose>
          <xsl:when test="$summary">
            <xsl:copy-of select="$summary" />
          </xsl:when>
          <xsl:otherwise>
            <collection>
              <xsl:variable name="title">
                <xsl:for-each select="archdesc/did/unittitle//text()">
                  <xsl:value-of select="current()" />
                </xsl:for-each>
              </xsl:variable>
              <title><xsl:value-of select="normalize-space($title)"></xsl:value-of></title>
              <xsl:if test="archdesc/did/head">
                <xsl:for-each select="archdesc/did[head]">
                  <descsummary>
                  <head><xsl:value-of select="head" /></head>
                  <xsl:for-each select="node()[@label]">
                    <field>
                      <head><xsl:value-of select="@label" /></head>
                      <value><xsl:value-of select="node()" /></value>
                    </field>
                  </xsl:for-each>
                  </descsummary>
                </xsl:for-each>
              </xsl:if>
              <xsl:for-each select="archdesc/descgrp[@type='admininfo']">
                <admininfo>
                  <head><xsl:value-of select="head" /></head>
                  <xsl:for-each select="node()[head]">
                    <field>
                      <head><xsl:value-of select="head" /></head>
                      <value><xsl:value-of select="p" /></value>
                    </field>
                  </xsl:for-each>
                </admininfo>
              </xsl:for-each>
              <xsl:variable name="bioghistCount" select="count(archdesc/bioghist/p)" />
              <xsl:if test="$bioghistCount &gt; 0">
                <bioghist>
                  <p_count><xsl:value-of select="$bioghistCount" /></p_count>
                  <head><xsl:value-of select="archdesc/bioghist/head[1]" /></head>
                  <xsl:for-each select="archdesc/bioghist/p[position()]">
                    <xsl:variable name="p">
                      <xsl:for-each select="current()//text()">
                        <xsl:value-of select="current()" />
                      </xsl:for-each>
                    </xsl:variable>
                    <p><xsl:value-of select="normalize-space($p)" /></p>
                  </xsl:for-each>
                </bioghist>
              </xsl:if>
              <xsl:variable name="count" select="count(archdesc/scopecontent/p)" />
              <xsl:if test="$count &gt; 0">
                <scopecontent>
                  <p_count><xsl:value-of select="$count"></xsl:value-of></p_count>
                  <head><xsl:value-of select="archdesc/scopecontent/head[1]" /></head>
                  <xsl:for-each select="archdesc/scopecontent/p[position()]">
                    <xsl:variable name="p">
                      <xsl:for-each select="current()//text()">
                        <xsl:value-of select="current()" />
                      </xsl:for-each>
                    </xsl:variable>
                    <p><xsl:value-of select="normalize-space($p)" /></p>
                  </xsl:for-each>
                </scopecontent>
              </xsl:if>
              
              <xsl:variable name="firstChildUri">
                <xsl:call-template name="lookupFirstPart">
                  <xsl:with-param name="parentPid" select="$pid" />
                </xsl:call-template>
              </xsl:variable>
              
              <xsl:if test="$firstChildUri != ''">
                <xsl:variable name="subsequentSparql">
                  <xsl:call-template name="lookupSubsequentParts"><xsl:with-param name="parentPid" select="$pid" /></xsl:call-template>
                </xsl:variable>
                <xsl:variable name="count" select="1 + count($subsequentSparql//s:sparql/s:results/s:result)" />
                
                <xsl:variable name="exemplarSparql">
                  <xsl:call-template name="lookupPartsDigitizedExemplars">
                    <xsl:with-param name="componentPid" select="$pid" />
                  </xsl:call-template>
                </xsl:variable>
                
                <component_count><xsl:value-of select="$count" /></component_count>
                <digitized_component_count><xsl:value-of select="count($exemplarSparql/s:sparql/s:results/s:result)" /></digitized_component_count>
                <xsl:call-template name="outputChildComponents">
                  <xsl:with-param name="iteration" select="1" />
                  <xsl:with-param name="current" select="$firstChildUri"></xsl:with-param>
                  <xsl:with-param name="nextMap" select="$subsequentSparql" />
                  <xsl:with-param name="exemplarMap" select="$exemplarSparql" />
                  <xsl:with-param name="depth" select="0" />
                </xsl:call-template>
              </xsl:if>
            </collection>
          </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="node()[starts-with(name(), 'c0')]">
        <component>
            <breadcrumbs>
                <xsl:call-template name="outputBreadcrumbs">
                    <xsl:with-param name="pid" select="$pid" />
                </xsl:call-template>
            </breadcrumbs>
            <xsl:variable name="unittitle">
                <xsl:for-each select="//did/unittitle//text()">
                    <xsl:value-of select="current()" />
                </xsl:for-each>
            </xsl:variable>
            <type><xsl:value-of select="//@level"></xsl:value-of></type>
            <xsl:if test="//head">
                <head><xsl:value-of select="//head" /></head>
            </xsl:if>
            <unittitle><xsl:value-of select="normalize-space($unittitle)"></xsl:value-of></unittitle>
            <xsl:variable name="count" select="count(//scopecontent/p)" />
            <xsl:if test="$count &gt; 0">
                <scopecontent>
                    <p_count><xsl:value-of select="$count"></xsl:value-of></p_count>
                    <xsl:for-each select="//scopecontent/p[position()]">
                        <xsl:variable name="p">
                            <xsl:for-each select="current()//text()">
                                <xsl:value-of select="current()" />
                            </xsl:for-each>
                        </xsl:variable>
                        <p><xsl:value-of select="normalize-space($p)" /></p>
                    </xsl:for-each>
                </scopecontent>
            </xsl:if>
            
            <xsl:variable name="firstChildUri">
                <xsl:call-template name="lookupFirstPart">
                    <xsl:with-param name="parentPid" select="$pid" />
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:if test="$firstChildUri != ''">
                <xsl:variable name="subsequentSparql">
                    <xsl:call-template name="lookupSubsequentParts"><xsl:with-param name="parentPid" select="$pid" /></xsl:call-template>
                </xsl:variable>
                <xsl:variable name="count" select="1 + count($subsequentSparql//s:sparql/s:results/s:result)" />
                
                <xsl:variable name="exemplarSparql">
                    <xsl:call-template name="lookupPartsDigitizedExemplars">
                        <xsl:with-param name="componentPid" select="$pid" />
                    </xsl:call-template>
                </xsl:variable>
                
                <component_count><xsl:value-of select="$count" /></component_count>
                <digitized_component_count><xsl:value-of select="count($exemplarSparql/s:sparql/s:results/s:result)" /></digitized_component_count>
                <xsl:call-template name="outputChildComponents">
                    <xsl:with-param name="iteration" select="1" />
                    <xsl:with-param name="current" select="$firstChildUri"></xsl:with-param>
                    <xsl:with-param name="nextMap" select="$subsequentSparql" />
                    <xsl:with-param name="exemplarMap" select="$exemplarSparql" />
                    <xsl:with-param name="depth" select="0" />
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$firstChildUri = ''">
                <xsl:variable name="digitalExemplarUri">
                    <xsl:call-template name="lookupDigitizedExemplar">
                        <xsl:with-param name="itemPid" select="$pid" />
                    </xsl:call-template>
                </xsl:variable>
                <xsl:if test="$digitalExemplarUri != ''">
                    <digital_exemplar><xsl:value-of select="substring($digitalExemplarUri, string-length('info:fedora/') + 1)" /></digital_exemplar>
                </xsl:if>
            </xsl:if>
        </component>
    </xsl:template>
    
    <xsl:template name="outputChildComponents">
        <xsl:param name="iteration" required="yes" />
        <xsl:param name="current" required="yes" />
        <xsl:param name="nextMap" required="yes" />
        <xsl:param name="exemplarMap" required="yes" />
        <xsl:param name="depth" required="yes" />
        <xsl:message>outputChildComponents <xsl:value-of select="$iteration" /> - <xsl:value-of select="$depth" /></xsl:message>
        <xsl:variable name="currentPid" select="substring($current, string-length('info:fedora/') + 1)" />
        <xsl:if test="$depth &lt; 1 or $iteration &lt;= number($component_max)">
            <xsl:variable name="currentMetadataUrl">
                <xsl:text>http://</xsl:text><xsl:value-of select="$fedora-host" /><xsl:text>:8080/fedora/objects/</xsl:text>
                <xsl:value-of select="$currentPid" />
                <xsl:text>/methods/uva-lib:descMetadataSDef/getMetadataAsEADFragment</xsl:text>
            </xsl:variable>
            <xsl:if test="$debug">
                <xsl:message terminate="no">
                    Querying for the metadata for <xsl:value-of select="$currentPid" /> using query: <xsl:value-of select="$currentMetadataUrl" />
                </xsl:message>
            </xsl:if>
            <xsl:variable name="currentMetadataFragment" select="document($currentMetadataUrl)" />
            <component>
                <id><xsl:value-of select="$currentPid" /></id>
                <type><xsl:value-of select="$currentMetadataFragment//@level"></xsl:value-of></type>
                <xsl:if test="$currentMetadataFragment//head">
                    <head><xsl:value-of select="$currentMetadataFragment//head" /></head>
                </xsl:if>
                <xsl:variable name="unittitle">
                    <xsl:for-each select="$currentMetadataFragment//did/unittitle//text()">
                        <xsl:value-of select="current()" />
                    </xsl:for-each>
                </xsl:variable>
                <xsl:if test="$unittitle">
                    <unittitle><xsl:value-of select="normalize-space($unittitle)" /></unittitle>
                </xsl:if>
                <xsl:if test="count($currentMetadataFragment//scopecontent/p) &gt; 0">
                    <scopecontent>
                        <p_count><xsl:value-of select="count($currentMetadataFragment//scopecontent/p)"></xsl:value-of></p_count>
                        <xsl:for-each select="$currentMetadataFragment//scopecontent/p[position()]">
                            <xsl:variable name="p">
                                <xsl:for-each select="current()//text()">
                                    <xsl:value-of select="current()" />
                                </xsl:for-each>
                            </xsl:variable>
                            <p><xsl:value-of select="normalize-space($p)" /></p>
                        </xsl:for-each>
                    </scopecontent>
                </xsl:if>

                <xsl:variable name="firstChildUri">
                    <xsl:call-template name="lookupFirstPart">
                        <xsl:with-param name="parentPid" select="$currentPid" />
                    </xsl:call-template>
                </xsl:variable>
                
                <xsl:if test="$firstChildUri != ''">
                    <xsl:variable name="subsequentSparql">
                        <xsl:call-template name="lookupSubsequentParts"><xsl:with-param name="parentPid" select="$currentPid" /></xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="count" select="1 + count($subsequentSparql//s:sparql/s:results/s:result)" />
                    
                    <xsl:variable name="exemplarSparql">
                        <xsl:call-template name="lookupPartsDigitizedExemplars">
                            <xsl:with-param name="componentPid" select="$currentPid" />
                        </xsl:call-template>
                    </xsl:variable>

                    <component_count><xsl:value-of select="$count" /></component_count>
                    <digitized_component_count><xsl:value-of select="count($exemplarSparql/s:sparql/s:results/s:result)" /></digitized_component_count>
                    <xsl:if test="$count &gt; 0">
                        <xsl:call-template name="outputChildComponents">
                            <xsl:with-param name="iteration" select="1" />
                            <xsl:with-param name="current" select="$firstChildUri"></xsl:with-param>
                            <xsl:with-param name="nextMap" select="$subsequentSparql" />
                            <xsl:with-param name="exemplarMap" select="$exemplarSparql" />
                            <xsl:with-param name="depth" select="$depth + 1"></xsl:with-param>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:if>
                <xsl:variable name="digitalExemplarUri">
                    <xsl:value-of select="$exemplarMap/s:sparql/s:results/s:result[s:childComponent/@uri=$current]/s:exemplar/@uri" />
                </xsl:variable>
                <xsl:if test="$digitalExemplarUri != ''">
                    <digital_exemplar><xsl:value-of select="substring($digitalExemplarUri, string-length('info:fedora/') + 1)" /></digital_exemplar>
                </xsl:if>
            </component>
            <xsl:variable name="nextUri" select="$nextMap/s:sparql/s:results/s:result[s:previous/@uri=$current]/s:next/@uri" />
            <xsl:if test="$nextUri">
                <xsl:call-template name="outputChildComponents">
                    <xsl:with-param name="iteration" select="$iteration + 1" />
                    <xsl:with-param name="current" select="$nextUri"></xsl:with-param>
                    <xsl:with-param name="nextMap" select="$nextMap" />
                    <xsl:with-param name="exemplarMap" select="$exemplarMap" />
                    <xsl:with-param name="depth" select="$depth" />
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <!-- 
        Perform one query to find the parent object:
        select $parent from <#ri> where <info:fedora/$pid> <info:fedora/fedora-system:def/relations-external#isPartOf> $parent
        
    -->  
    <xsl:template name="outputBreadcrumbs">
        <xsl:param name="pid"/>
        
        <xsl:variable name="lookupParentUri">
            <xsl:text>http://</xsl:text><xsl:value-of select="$fedora-host" /><xsl:text>:8080/fedora/risearch?type=tuples&amp;lang=itql&amp;format=Sparql&amp;query=select%20%24parent%20from%20%3C%23ri%3E%20where%20%3Cinfo%3Afedora%2F</xsl:text>
            <xsl:value-of select="$pid" />
            <xsl:text>%3E%20%3Cinfo%3Afedora%2Ffedora-system%3Adef%2Frelations-external%23isPartOf%3E%20%24parent</xsl:text>
        </xsl:variable>
        <xsl:if test="$debug = true()">
            <xsl:message>
                Querying for parent of <xsl:value-of select="$pid" /> using query: <xsl:value-of select="$lookupParentUri" />
            </xsl:message>
        </xsl:if>
        <xsl:variable name="parentPid" select="substring(document($lookupParentUri)/s:sparql/s:results/s:result/s:parent/@uri, string-length('info:fedora/') + 1)" />
        
        <xsl:if test="$parentPid">
            
            <xsl:call-template name="outputBreadcrumbs">
                <xsl:with-param name="pid" select="$parentPid" />
            </xsl:call-template>
            
            <xsl:variable name="parentMetadataUrl">
                <xsl:text>http://</xsl:text><xsl:value-of select="$fedora-host" /><xsl:text>:8080/fedora/objects/</xsl:text>
                <xsl:value-of select="$parentPid" />
                <xsl:text>/methods/uva-lib:descMetadataSDef/getMetadataAsEADFragment</xsl:text>
            </xsl:variable>
            <xsl:if test="$debug = true()">
                <xsl:message>
                    Querying for the metadata for <xsl:value-of select="$parentPid" /> using query: <xsl:value-of select="$parentMetadataUrl" />
                </xsl:message>
            </xsl:if>
            <xsl:variable name="parentMetadataFragment" select="document($parentMetadataUrl)" />
            <xsl:variable name="title">
                <xsl:choose>
                    <xsl:when test="$parentMetadataFragment//ead/frontmatter/titlepage/titleproper">
                        <xsl:for-each select="$parentMetadataFragment//ead/frontmatter/titlepage/titleproper//text()">
                            <xsl:value-of select="current()" />
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="$parentMetadataFragment//did/unittitle//text()">
                            <xsl:value-of select="current()" />
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <ancestor>
                <id><xsl:value-of select="$parentPid"></xsl:value-of></id>
                <title><xsl:value-of select="normalize-space($title)" /></title>
            </ancestor>
        </xsl:if>
    </xsl:template>
    
    
    <!-- Performs a fedora resource index query that will return a sparql result containing
         pairs of object URIs for all the parts of the given parent except the first with a
         reference to the preceding part (pervious and next).
         -->
    <xsl:template name="lookupSubsequentParts">
        <xsl:param name="parentPid" required="yes" />
        <xsl:variable name="lookupSubsequentChildrenUri">
            <xsl:text>http://</xsl:text><xsl:value-of select="$fedora-host" /><xsl:text>:8080/fedora/risearch?type=tuples&amp;lang=itql&amp;format=Sparql&amp;query=select%20%24next%20%24previous%20from%20%3C%23ri%3E%20where%20%24next%20%3Cinfo%3Afedora%2Ffedora-system%3Adef%2Frelations-external%23isPartOf%3E%20%3Cinfo%3Afedora%2F</xsl:text>
            <xsl:value-of select="$parentPid" />
            <xsl:text>%3E%20and%20%24next%20%3Chttp%3A%2F%2Ffedora.lib.virginia.edu%2Frelationships%23follows%3E%20%24previous</xsl:text>
        </xsl:variable>
        <xsl:if test="$debug">
            <xsl:message terminate="no">
                Querying for subsequent parts of <xsl:value-of select="$parentPid" /> using query: <xsl:value-of select="$lookupSubsequentChildrenUri" />
            </xsl:message>
        </xsl:if>
        <xsl:copy-of select="document($lookupSubsequentChildrenUri)" />
    </xsl:template>
    
    <!-- Performs a fedora resource index query to detect the first object
         that is the object of an "isPartOf" relationship with the given
         parentPid.   This template outputs just the text of the object uri
         or nothing if no pid is returned.
    -->
    <xsl:template name="lookupFirstPart">
        <xsl:param name="parentPid" required="yes" />
        <xsl:variable name="lookupFirstChildUri">
            <xsl:text>http://</xsl:text><xsl:value-of select="$fedora-host" /><xsl:text>:8080/fedora/risearch?type=tuples&amp;lang=itql&amp;format=Sparql&amp;query=select%20%24first%20from%20%3C%23ri%3E%20where%20%24first%20%20%3Cinfo%3Afedora%2Ffedora-system%3Adef%2Frelations-external%23isPartOf%3E%20%3Cinfo%3Afedora%2F</xsl:text>
            <xsl:value-of select="$parentPid" />
            <xsl:text>%3E%20minus%20%24first%20%3Chttp%3A%2F%2Ffedora.lib.virginia.edu%2Frelationships%23follows%3E%20%24other</xsl:text>
        </xsl:variable>
        <xsl:if test="$debug">
            <xsl:message terminate="no">
                Querying for first part of <xsl:value-of select="$parentPid" /> using query: <xsl:value-of select="$lookupFirstChildUri" />
            </xsl:message>
        </xsl:if>
        <xsl:value-of select="document($lookupFirstChildUri)/s:sparql/s:results/s:result/s:first/@uri" />
    </xsl:template>
    
    <!-- Performs a fedora resource index query that will return a sparql result containing
         pairs of object URIs (childComponent and exemplar) for which each childComponent
         is an item (that is a part of the supplied componentPid) and the exemplar is the
         digital representation that can be used as a preview image for the digitzed version
         of the object.  Only parts that represent digitized items will appear in the 
         resulting sparql -->
    <xsl:template name="lookupPartsDigitizedExemplars">
        <xsl:param name="componentPid" required="yes" />
        <xsl:variable name="lookupExemplars">
            <xsl:text>http://</xsl:text><xsl:value-of select="$fedora-host" /><xsl:text>:8080/fedora/risearch?type=tuples&amp;lang=itql&amp;format=Sparql&amp;query=select%20%24childComponent%20%24exemplar%20from%20%3C%23ri%3E%20where%20%24childComponent%20%3Cinfo%3Afedora%2Ffedora-system%3Adef%2Frelations-external%23isPartOf%3E%20%3Cinfo%3Afedora%2F</xsl:text>
            <xsl:value-of select="$componentPid" />
            <xsl:text>%3E%20and%20%24childComponent%20%3Chttp%3A%2F%2Ffedora.lib.virginia.edu%2Frelationships%23isPlaceholderFor%3E%20%24real%20and%20%24real%20%3Chttp%3A%2F%2Ffedora.lib.virginia.edu%2Frelationships%23hasDigitalRepresentation%3E%20%24exemplar%20and%20%24real%20%3Chttp%3A%2F%2Ffedora.lib.virginia.edu%2Frelationships%23hasExemplar%3E%20%24exemplar</xsl:text>
        </xsl:variable>
        <xsl:if test="$debug">
            <xsl:message terminate="no">
                Querying for the exemplar digitized versions for all parts of <xsl:value-of select="$componentPid" /> using query: <xsl:value-of select="$lookupExemplars" />
            </xsl:message>
        </xsl:if>
        <xsl:copy-of select="document($lookupExemplars)" />
    </xsl:template>
    
    <!-- Performs a fedora resource index query that will return the object uri of the 
        exemplar (digital representation) of the provided item if a digitized version
        exists for that item.
    -->
    <xsl:template name="lookupDigitizedExemplar">
        <xsl:param name="itemPid" required="yes" />
        <xsl:variable name="lookupExemplars">
            <xsl:text>http://</xsl:text><xsl:value-of select="$fedora-host" /><xsl:text>:8080/fedora/risearch?type=tuples&amp;lang=itql&amp;format=Sparql&amp;query=select%20%24exemplar%20from%20%3C%23ri%3E%20where%20%3Cinfo%3Afedora%2F</xsl:text>
            <xsl:value-of select="$itemPid" />
            <xsl:text>%3E%20%3Chttp%3A%2F%2Ffedora.lib.virginia.edu%2Frelationships%23isPlaceholderFor%3E%20%24real%20and%20%24real%20%3Chttp%3A%2F%2Ffedora.lib.virginia.edu%2Frelationships%23hasDigitalRepresentation%3E%20%24exemplar%20and%20%24real%20%3Chttp%3A%2F%2Ffedora.lib.virginia.edu%2Frelationships%23hasExemplar%3E%20%24exemplar</xsl:text>
        </xsl:variable>
        <xsl:if test="$debug">
            <xsl:message terminate="no">
                Querying for the exemplar digitized version of <xsl:value-of select="$itemPid" /> using query: <xsl:value-of select="$lookupExemplars" />
            </xsl:message>
        </xsl:if>
        <xsl:value-of select="document($lookupExemplars)/s:sparql/s:results/s:result/s:exemplar/@uri" />
    </xsl:template>
    
</xsl:stylesheet>