<?xml version="1.0" encoding="UTF-8"?>
<!--
   - An XSLT that takes an EAD-fragment along with a fedora PID and builds
   - a SOLR index document that contains the information directly from that
   - record as well as from all records related to the given PID 
   - hierarchically.
   -
   - Besides those fiels normally recognized by Virgo, this transformation
   - includes the special purpose fields:
   - hierarchy_display, full_hierarchy_display - contain an XML summary of
   -        the descendants of the record.
   - breadcrumbs_display - contains an XML summary of the ancestors of the
   -        record.
   - scope_content_display - contains the HTML formatted scope content
   - container_display - contains XML information about the physical 
   -        container in which the item described by the record exists.
   - digitized_item_pid_display - contains the PID for the object in 
   -        fedora that contains the digitized item.
  -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:s="http://www.w3.org/2001/sw/DataAccess/rf1/result"
    xmlns:marc="http://www.loc.gov/MARC21/slim"
    xmlns:doc="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mapping="http://lib.virginia.edu/mapping"
    xmlns:apia="http://www.fedora.info/definitions/1/0/access/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:uva-rels="http://fedora.lib.virginia.edu/relationships#"
    exclude-result-prefixes="xs s marc doc mapping apia rdf uva-rels"
    version="2.0">

    <!-- 
        A URL of a simple mapping from the ISO 639.2 language codes to the
        human readable name 
    -->
    <xsl:variable name="iso6392">
        <xsl:text>http://fedora-prod02.lib.virginia.edu:8080/fedora/objects/uva-lib:ISO639.2/datastreams/XML/content</xsl:text>
    </xsl:variable>

    <xsl:output byte-order-mark="no" encoding="UTF-8" media-type="text/xml" xml:space="preserve" indent="yes"/>
    
    <xsl:param name="fedora-host" required="no">fedora-prod02.lib.virginia.edu</xsl:param>
    <xsl:param name="fedora-proxy" required="no">http://fedoraproxy.lib.virginia.edu/fedora</xsl:param>
    <xsl:param name="pid" required="yes" />
    <xsl:param name="debug" required="no" />
    <xsl:param name="released-facet" required="no" />
    
    <xsl:template match="*" priority="-1" mode="primary" />
    <xsl:template match="*" priority="-1" mode="subsequent" />

    <doc:doc>
        <doc:desc>
            <doc:p>
                This matches the root of the MODS document and outputs a corresponding SOLR add document.
                This transformation was written for the Holsinger Stuido Collection and makes assumptions
                about the structure of the incoming MODS document that may be unsuitable for other materials.
            </doc:p>
            <doc:p>
                The following solr fields are automatically populated:
                <doc:ul>
                    <doc:li mapping:type="solrField" mapping:sourceXPath="$pid">id</doc:li>
                    <doc:li mapping:type="solrField" mapping:sourceXPath="[the various fedora content models]">content_model_facet</doc:li>
                    <doc:li mapping:type="solrField" mapping:sourceXPath="'UVA Library Digital Repository'">source_facet</doc:li>
                    <doc:li mapping:type="solrField" mapping:sourceXPath="'Special Collections'">library_facet</doc:li>
                    <doc:li mapping:type="solrField" mapping:sourceXPath="'Special Collections'">location_facet</doc:li>
                    <doc:li mapping:type="solrField" mapping:sourceXPath="'VISIBLE', 'HIDDEN' or 'UNDISCOVERABLE'">shadowed_location_facet</doc:li>
                    <doc:li mapping:type="solrField" mapping:sourceXPath="$released-facet">released_facet</doc:li>
                </doc:ul>
            </doc:p>
        </doc:desc>
    </doc:doc>
    <xsl:template match="/">
        <add>
            <doc>
                <field name="id"><xsl:value-of select="$pid"/></field>
                <field name="source_facet">UVA Library Digital Repository</field>
                <field name="format_facet">Manuscripts &amp; Rare Materials</field>
                <xsl:if test="$released-facet">
                    <field name="released_facet"><xsl:value-of select="$released-facet" /></field>
                </xsl:if>
              <!-- The early examples don't really fit this category.  While this was the value
                   suggested in the early wireframes, for the Daily Progress and WSLS collections
                   this doesn't make much sense.
                <field name="format_facet">Manuscripts &amp; Rare Materials</field>
              -->
              
                <!-- pull some information from fedora for:
                    date_received_facet 
                    content_model_facet 
                -->
                <xsl:variable name="objectProfile" select="document(concat('http://', $fedora-host, ':8080/fedora/objects/', $pid, '?format=xml'))" />
                <xsl:for-each select="$objectProfile/apia:objectProfile/apia:objModels/apia:model">
                    <xsl:if test="not(starts-with(current(), 'info:fedora/fedora-system'))">
                        <field name="content_model_facet"><xsl:value-of select="substring(text(), string-length('info:fedora/') + 1)" /></field>
                    </xsl:if>
                </xsl:for-each>
                <xsl:variable name="createDate" select="$objectProfile/apia:objectProfile/apia:objCreateDate/text()" />
                <field name="date_received_facet">
                    <xsl:value-of select="concat(substring($createDate, 1, 4), substring($createDate, 6, 2), substring($createDate, 9, 2))" />
                </field>
                
                <xsl:variable name="relsExt" select="document(concat('http://', $fedora-host, ':8080/fedora/objects/', $pid, '/datastreams/RELS-EXT/content'))" />
                <xsl:variable name="visibility" select="$relsExt/rdf:RDF/rdf:Description/uva-rels:visibility" />
                <xsl:if test="not($visibility)">
                    <field name="shadowed_location_facet"><xsl:text>VISIBLE</xsl:text></field>
                </xsl:if>
                <xsl:if test="$visibility">
                    <field name="shadowed_location_facet"><xsl:value-of select="$visibility" /></field>
                </xsl:if>

                <xsl:apply-templates select="//*" mode="primary" />
                
                <xsl:variable name="ancestors">
                    <xsl:call-template name="get-ancestry">
                        <xsl:with-param name="pid" select="$pid" />
                    </xsl:call-template>
                </xsl:variable>
                
                <xsl:call-template name="index-ancestors">
                    <xsl:with-param name="ancestors" select="$ancestors" />
                </xsl:call-template>
                    
                <!-- Add the breadcrumbs display -->
                <field name="breadcrumbs_display">
                    <xsl:text>&lt;breadcrumbs&gt;</xsl:text>
                    <xsl:for-each select="$ancestors/ancestor">
                        <xsl:text>&lt;ancestor&gt;</xsl:text>
                        <xsl:text>&lt;id&gt;</xsl:text><xsl:value-of select="pid" /><xsl:text>&lt;/id&gt;</xsl:text>
                        
                        <xsl:variable name="title">
                            <xsl:choose>
                                <xsl:when test="current()//ead/frontmatter/titlepage/titleproper">
                                    <xsl:for-each select="current()//ead/frontmatter/titlepage/titleproper//text()">
                                        <xsl:value-of select="current()" />
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:for-each select="current()//did/unittitle//text()">
                                        <xsl:value-of select="current()" />
                                    </xsl:for-each>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        
                        <xsl:text>&lt;title&gt;</xsl:text>
                        <xsl:value-of select="$title" />
                        <xsl:text>&lt;/title&gt;</xsl:text>
                        <xsl:text>&lt;/ancestor&gt;</xsl:text>
                    </xsl:for-each>
                    <xsl:text>&lt;/breadcrumbs&gt;</xsl:text>
                </field>
                
                <!-- Add the hierarchy display -->
                <xsl:variable name="summary" select="unparsed-text(concat('http://', $fedora-host, ':8080/fedora/objects/', $pid, '/methods/uva-lib:hierarchicalMetadataSDef/getSummary'))" />
                <field name="hierarchy_display">
                    <xsl:value-of select="$summary" />
                </field>
                
                <!-- Add the container information -->
                <xsl:variable name="container">
                    <xsl:call-template name="index-containers">
                        <xsl:with-param name="pid" select="$pid" />
                        <xsl:with-param name="ancestry" select="$ancestors" />
                    </xsl:call-template>
                </xsl:variable>
                <xsl:if test="string-length($container) &gt; 0">
                    <field name="container_display">
                        <xsl:copy-of select="$container" />
                    </field>
                </xsl:if>
                
                <!-- Add all information from MARC if possible -->
                <xsl:call-template name="index-marc">
                    <xsl:with-param name="pid" select="$pid" />
                    <xsl:with-param name="mode" select="'primary'"/>
                </xsl:call-template>
            </doc>
        </add>
    </xsl:template>
    
    <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz '"/>
    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ-,;:.'"/>
    
    <doc:doc>
        <doc:desc>
            <doc:ul>
                <doc:li mapping:type="solrField">repository_name_display</doc:li>
            </doc:ul>
        </doc:desc>
    </doc:doc>
    <xsl:template match="ead/archdesc/did/repository" mode="#all">
        <field name="repository_name_display">
            <xsl:value-of select="normalize-space(text())"></xsl:value-of>
        </field>
    </xsl:template>
    
    <doc:doc>
        <doc:desc>
            <doc:ul>
                <doc:li mapping:type="solrField">call_number_display</doc:li>
                <doc:li mapping:type="solrField">call_number_facet</doc:li>
            </doc:ul>
        </doc:desc>
    </doc:doc>
    <xsl:template match="ead/archdesc/did/unitid" mode="#all">
        <field name="call_number_facet"><xsl:value-of select="normalize-space(text())" /></field>
        <field name="call_number_display"><xsl:value-of select="normalize-space(text())" /></field>
    </xsl:template>
    
    <doc:doc>
        <doc:desc>
            <doc:ul>
                <doc:li mapping:type="solrField">creator_display</doc:li>
                <doc:li mapping:type="solrField">author_facet</doc:li>
            </doc:ul>
        </doc:desc>
    </doc:doc>
    <xsl:template match="datafield[@tag='100']/subfield[@code='a']" mode="primary">
        <xsl:variable name="creator">
            <xsl:if test="ends-with(text(), ',')">
                <xsl:value-of select="substring(text(), 1, string-length(text()) - 1)" />
            </xsl:if>
            <xsl:if test="not(ends-with(text(), ','))">
                <xsl:value-of select="text()" />
            </xsl:if>
        </xsl:variable>
        <field name="creator_display">
            <xsl:value-of select="$creator"></xsl:value-of>
        </field>
        <field name="author_facet">
            <xsl:value-of select="$creator"></xsl:value-of>
        </field>
    </xsl:template>
    
    <doc:doc>
        <doc:desc>
            <doc:ul>
                <doc:li mapping:type="solrField" mapping:sourceXPath="'More than 50 years ago'">published_date_facet</doc:li>
                <doc:li mapping:type="solrField">date_display</doc:li>
            </doc:ul>
        </doc:desc>
    </doc:doc>
    <xsl:template match="unitdate" mode="primary">
        <field name="date_display">
            <xsl:value-of select="text()" />
        </field>
        <!--
            We'll have to parse out the date into something structured
        
        <field name="year_multisort_i">
            
        </field>
        -->
        <!-- this is hard-coded for now -->
        <field name="published_date_facet">
            <xsl:text>More than 50 years ago</xsl:text>
        </field>
    </xsl:template>
    
    <doc:doc>
        <doc:desc>
            <doc:ul>
                <doc:li mapping:type="solrField">main_title_display</doc:li>
                <doc:li mapping:type="solrField">title_display</doc:li>
                <doc:li mapping:type="solrField">title_text</doc:li>
                <doc:li mapping:type="solrField">digital_collection_facet</doc:li>
            </doc:ul>
        </doc:desc>
    </doc:doc>
    <xsl:template match="ead/archdesc/did/unittitle[1]" mode="primary">
        <xsl:variable name="title">
            <xsl:for-each select="current()//text()">
                <xsl:value-of select="current()" />
            </xsl:for-each>
        </xsl:variable>
        <field name="main_title_display"><xsl:value-of select="normalize-space($title)" /></field>
        <field name="title_display"><xsl:value-of select="normalize-space($title)" /></field>
        <field name="title_text" boost="2.0"><xsl:value-of select="normalize-space($title)"></xsl:value-of></field>
        <field name="digital_collection_facet"><xsl:value-of select="normalize-space($title)" /></field>
    </xsl:template>
    
    <doc:doc>
        <doc:desc>
            <doc:ul>
                <doc:li mapping:type="solrField">collection_title_display</doc:li>
                <doc:li mapping:type="solrField">digital_collection_facet</doc:li>
                <doc:li mapping:type="solrField">collection_title_text</doc:li>
            </doc:ul>
        </doc:desc>
    </doc:doc>
    <xsl:template match="ead/archdesc/did/unittitle" mode="subsequent">
        <xsl:variable name="title">
            <xsl:for-each select="current()//text()">
                <xsl:value-of select="current()" />
            </xsl:for-each>
        </xsl:variable>
        <field name="collection_title_display"><xsl:value-of select="normalize-space($title)" /></field>
        <field name="digital_collection_facet"><xsl:value-of select="normalize-space($title)" /></field>
        <field name="collection_title_text" boost="0.25"><xsl:value-of select="normalize-space($title)"></xsl:value-of></field>
    </xsl:template>
    
    <doc:doc>
        <doc:desc>
            <doc:ul>
                <doc:li mapping:type="solrField">library_facet</doc:li>
                <doc:li mapping:type="solrField">location_facet</doc:li>
            </doc:ul>
        </doc:desc>
    </doc:doc>
    <xsl:template match="filedesc/publicationstmt/publisher" mode="primary subsequent">
        <field name="library_facet">
            <xsl:value-of select="normalize-space(text())" />
        </field>
        <field name="location_facet">
            <xsl:value-of select="normalize-space(text())" />
        </field>
    </xsl:template>
    
    <doc:doc>
        <doc:desc>
            <doc:ul>
                <doc:li mapping:type="solrField">scope_content_display</doc:li>
                <doc:li mapping:type="solrField">scope_content_text</doc:li>
            </doc:ul>
        </doc:desc>
    </doc:doc>
    <xsl:template match="scopecontent" mode="primary">
        <xsl:variable name="content">
            <xsl:for-each select="current()//text()">
                <xsl:value-of select="current()" />
            </xsl:for-each>
        </xsl:variable>
        <field name="scope_content_text"><xsl:value-of select="normalize-space($content)" /></field>
        
        <field name="scope_content_display">
          <xsl:text>&lt;scopecontent&gt;</xsl:text>
            <xsl:for-each select="current()/p">
                <xsl:variable name="p">
                    <xsl:for-each select="current()//text()">
                        <xsl:text>&lt;![CDATA[</xsl:text>
                            <xsl:value-of select="current()" />
                        <xsl:text>]]&gt;</xsl:text>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:text>&lt;p&gt;</xsl:text>
                    <xsl:value-of select="normalize-space($p)" />
                <xsl:text>&lt;/p&gt;</xsl:text>
            </xsl:for-each>
        <xsl:text>&lt;/scopecontent&gt;</xsl:text>
        </field>
    </xsl:template>
    
    <doc:doc>
        <doc:desc>
            <doc:ul>
                <doc:li mapping:type="solrField">extent_display</doc:li>
                <doc:li mapping:type="solrField">extent_text</doc:li>
            </doc:ul>
        </doc:desc>
    </doc:doc>
    <xsl:template match="physdesc[@label='Extent' or @label='extent']" mode="primary">
        <field name="extent_display"><xsl:value-of select="text()" /></field>
        <field name="extent_text"><xsl:value-of select="text()" /></field>
    </xsl:template>
    
    <doc:doc>
        <doc:desc>
            <doc:ul>
                <doc:li mapping:type="solrField">collection_abstract_display</doc:li>
                <doc:li mapping:type="solrField">colleciton_abstract_text</doc:li>
            </doc:ul>
        </doc:desc>
    </doc:doc>
    <xsl:template match="abstract" mode="#all">
        <xsl:variable name="abstract">
            <xsl:for-each select="current()//text()">
                <xsl:value-of select="current()" />
            </xsl:for-each>
        </xsl:variable>
        <field name="collection_abstract_display" boost="0.5"><xsl:value-of select="normalize-space($abstract)" /></field>
        <field name="collection_abstract_text" boost="0.5"><xsl:value-of select="normalize-space($abstract)" /></field>
    </xsl:template>
    
    <doc:doc>
        <doc:desc>
            <doc:p>
                This template matches any did/physdec with the text value of 'Map'and 
                builds the <doc:b mapping:type="solrField">format_facet</doc:b> and 
                <doc:b mapping:type="solrField">format_text</doc:b> SOLR fields from
                the various nested elements. 
            </doc:p>
        </doc:desc>
    </doc:doc>
    <xsl:template match="did/physdesc[text() = 'MAP']" mode="primary">
        <field name="format_facet">Map</field>
        <field name="format_text">Map</field>
    </xsl:template>
    
    <doc:doc>
        <doc:desc>
            <doc:p>
                This template matches any did/langmaterial/language with the text value of 'Map'and 
                builds the <doc:b mapping:type="solrField">language_facet</doc:b> SOLR field from
                the english rendering of the language specified by the given language code.
            </doc:p>
        </doc:desc>
    </doc:doc>
    <xsl:template match="did/langmaterial/language/@langcode" mode="primary">
        <xsl:if test="not(current()='zxx')">
            <xsl:variable name="languageCodeMapping" select="document($iso6392)" />
            <field name="language_facet">
                <xsl:value-of select="$languageCodeMapping/languages/language/english[../code/text()=current()]" />
            </field>
        </xsl:if>
        <field name="language_facet">Map</field>
        <field name="format_text">Map</field>
    </xsl:template>
    
    <doc:doc>
        <doc:desc>
            <doc:p>
                This template matches any userestrict elements to populate the 
                the <doc:b mapping:type="solrField">access_display</doc:b> and 
                <doc:b mapping:type="solrField">access_text</doc:b> SOLR fields from
                the various nested elements. 
            </doc:p>
        </doc:desc>
    </doc:doc>
    <xsl:template match="userestrict" mode="primary">
        <field name="access_display"><xsl:value-of select="head" /><xsl:text>: </xsl:text><xsl:value-of select="p" /></field>
        <field name="access_text"><xsl:value-of select="head" /><xsl:text>: </xsl:text><xsl:value-of select="p" /></field>
    </xsl:template>
    
    <doc:doc>
        <doc:desc>
            <doc:p>
                This template matches any accessestrict elements to populate the 
                the <doc:b mapping:type="solrField">access_display</doc:b> and 
                <doc:b mapping:type="solrField">access_text</doc:b> SOLR fields from
                the various nested elements. 
            </doc:p>
        </doc:desc>
    </doc:doc>
    <xsl:template match="accessrestrict" mode="primary">
        <field name="access_display"><xsl:value-of select="head" /><xsl:text>: </xsl:text><xsl:value-of select="p" /></field>
        <field name="access_text"><xsl:value-of select="head" /><xsl:text>: </xsl:text><xsl:value-of select="p" /></field>
    </xsl:template>
    
    
    <doc:doc>
        <doc:desc>
            <doc:p>
                Maps the unittitle to the following SOLR fields:
                <doc:ul>
                    <doc:li mapping:type="solrField">main_title_display</doc:li>
                    <doc:li mapping:type="solrField">title_display</doc:li>
                    <doc:li mapping:type="solrField">title_text</doc:li>
                    <doc:li mapping:type="full_title_text">full_title_text</doc:li>
                </doc:ul>
            </doc:p>
        </doc:desc>
    </doc:doc>
    <xsl:template match="unittitle" mode="primary">
        <xsl:variable name="title">
            <xsl:for-each select="current()//text()">
                <xsl:value-of select="current()" />
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="not(current()/preceding-sibling::unittitle)">
            <xsl:comment>Main Title</xsl:comment>
            <field name="main_title_display">
                <xsl:value-of select="normalize-space($title)"></xsl:value-of>
            </field>
        </xsl:if>
        <field name="title_display"><xsl:value-of select="normalize-space($title)" /></field>
        <field name="title_text"><xsl:value-of select="normalize-space($title)" /></field>
        <field name="full_title_text"><xsl:value-of select="normalize-space($title)" /></field>
    </xsl:template>
    
    <doc:doc>
        <doc:desc>
            <doc:ul>
                <doc:li mapping:type="solrField" mapping:sourceXPath="'ead/@id">ead_id_text</doc:li>
                <doc:li mapping:type="solrField" mapping:sourceXPath="'collection">hierarchy_level_facet</doc:li>
            </doc:ul>
        </doc:desc>
    </doc:doc>
    <xsl:template match="ead" mode="primary">
        <xsl:if test="@id">
            <field name="ead_id_text" boost="2.0"><xsl:value-of select="@id" /></field>
        </xsl:if>
        <field name="hierarchy_level_facet">collection</field>
        <xsl:if test="$debug">
            <xsl:comment>Matched EAD</xsl:comment>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="ead" mode="subsequent">
        <xsl:if test="@id">
            <field name="ead_id_text" boost="0.25"><xsl:value-of select="@id" /></field>
        </xsl:if>
        <xsl:if test="$debug">
            <xsl:comment>Matched EAD</xsl:comment>
        </xsl:if>
    </xsl:template>
    
    <doc:doc>
        <doc:desc>
            <doc:p mapping:type="solrField" mapping:sourceXPath="node()[starts-with(name(), 'c0')]/@level">hierarchy_level_facet</doc:p>
            <doc:p mapping:type="solrField" mapping:sourceXPath="'http://fedoraproxy.lib.virginia.edu/fedora' (if item is digitized)">repository_address_display</doc:p>
            <doc:p mapping:type="solrField" mapping:sourceXPath="id of the digized version of the item">digitized_item_pid_display</doc:p>
            <doc:p mapping:type="solrField" mapping:sourceXPath="'Online' if the item is digitized">format_facet</doc:p>
        </doc:desc>
    </doc:doc>
    <xsl:template match="node()[starts-with(name(), 'c0')]" mode="primary">
        <xsl:if test="$debug">
            <xsl:comment>Matched <xsl:value-of select="name()" /></xsl:comment>
        </xsl:if>
        <field name="hierarchy_level_facet"><xsl:value-of select="@level" /></field>
        <!--<field name="format_facet"><xsl:value-of select="@level" /></field>-->
        
        <xsl:if test="@level='item'">
            <xsl:variable name="digitizedItemUri">
                <xsl:call-template name="lookupDigitizedObject">
                    <xsl:with-param name="itemPid" select="$pid" />
                </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$digitizedItemUri != ''">
                <xsl:variable name="digitizedItemPid" select="substring($digitizedItemUri, 13)" />
                <field name="digitized_item_pid_display"><xsl:value-of select="$digitizedItemPid" /></field>
                <field name="repository_address_display"><xsl:value-of select="$fedora-proxy" /></field>
                <field name="format_facet"><xsl:text>Online</xsl:text></field>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="record" mode="#all">
        <xsl:if test="$debug">
            <xsl:comment>Matched MARC record</xsl:comment>
        </xsl:if>
    </xsl:template>

    <doc:doc>
        <doc:desc>
            <doc:p>
                When indexing the whole collection, this matches all personal names in marc
                records and stores them in the 
                <doc:b mapping:type="solrField">personal_name_display</doc:b> and
                <doc:b mapping:type="solrField">personal_name_text</doc:b> SOLR fields.
            </doc:p>
        </doc:desc>
    </doc:doc>
    <xsl:template match="record/datafield[@tag='600']" mode="primary">
        <xsl:variable name="name">
            <xsl:value-of select="subfield[@code='a']" />
            <xsl:text> </xsl:text>
            <xsl:value-of select="subfield[@code='d']" />
        </xsl:variable>
        <xsl:variable name="clean-name">
            <xsl:choose>
                <xsl:when test="ends-with($name, '.')">
                    <xsl:value-of select="normalize-space(substring($name, 1, string-length($name) - 1))" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space($name)" />                    
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <field name="personal_name_display"><xsl:value-of select="$clean-name" /></field>
        <field name="personal_name_text"><xsl:value-of select="$clean-name" /></field>
    </xsl:template>
    
    <doc:doc>
        <doc:desc>
            <doc:p>
                When indexing the whole collection, this matches all corporate names in marc
                records and stores them in the 
                <doc:b mapping:type="solrField">corporate_name_display</doc:b> and
                <doc:b mapping:type="solrField">corporate_name_text</doc:b> SOLR fields.
            </doc:p>
        </doc:desc>
    </doc:doc>
    <xsl:template match="record/datafield[@tag='610']/subfield[@code='a']" mode="primary">
        <xsl:variable name="subject">
            <xsl:choose>
                <xsl:when test="ends-with(text(), '.')">
                    <xsl:value-of select="normalize-space(substring(text(), 1, string-length(text()) - 1))" />
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="text()" /></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <field name="corporate_name_display"><xsl:value-of select="$subject" /></field>
        <field name="corporate_name_text"><xsl:value-of select="$subject" /></field>
    </xsl:template>

    <doc:doc>
        <doc:desc>
            <doc:p>
                When indexing the whole collection, this matches all personal names in marc
                records and stores them in the 
                <doc:b mapping:type="solrField">meeting_name_display</doc:b> and
                <doc:b mapping:type="solrField">meeting_name_text</doc:b> SOLR fields.
            </doc:p>
        </doc:desc>
    </doc:doc>
    <xsl:template match="record/datafield[@tag='611']/subfield[@code='a']" mode="primary">
        <xsl:variable name="subject">
            <xsl:choose>
                <xsl:when test="ends-with(text(), '.')">
                    <xsl:value-of select="normalize-space(substring(text(), 1, string-length(text()) - 1))" />
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="text()" /></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <field name="meeting_name_display"><xsl:value-of select="$subject" /></field>
        <field name="meeting_name_text"><xsl:value-of select="$subject" /></field>
    </xsl:template>

    <doc:doc>
        <doc:desc>
            <doc:p>
                When indexing the whole collection, this matches all topics in marc
                records and stores them in the 
                <doc:b mapping:type="solrField">subject_facet</doc:b> and
                <doc:b mapping:type="solrField">subject_text</doc:b> SOLR fields.
            </doc:p>
        </doc:desc>
    </doc:doc>
    <xsl:template match="record/datafield[@tag='650']/subfield[@code='a']" mode="primary">
        <field name="subject_facet"><xsl:value-of select="text()" /></field>
        <field name="subject_text"><xsl:value-of select="text()" /></field>
    </xsl:template>
    
    <doc:doc>
        <doc:desc>
            <doc:p>
                When indexing the whole collection, this matches all index terms for
                genre in marc records and stores them in the 
                <doc:b mapping:type="solrField">genre_text</doc:b> and
                <doc:b mapping:type="solrField">genre_display</doc:b> SOLR fields.
            </doc:p>
        </doc:desc>
    </doc:doc>
    <xsl:template match="record/datafield[@tag='655']/subfield[@code='a']" mode="primary">
        <xsl:variable name="subject">
            <xsl:choose>
                <xsl:when test="ends-with(text(), '.')">
                    <xsl:value-of select="normalize-space(substring(text(), 1, string-length(text()) - 1))" />
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="text()" /></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <field name="genre_display"><xsl:value-of select="$subject" /></field>
        <field name="genre_text"><xsl:value-of select="$subject" /></field>
    </xsl:template>

    <!--
        A recursive template to build an XML fragment that contains
        the metadata records for the objects that are the parent
        (and ancestors) of the object whose pid is passed to this
        template.
    -->
    <xsl:template name="get-ancestry">
        <xsl:param name="pid" />
        <xsl:variable name="lookupParentUri">
            <xsl:text>http://</xsl:text><xsl:value-of select="$fedora-host" /><xsl:text>:8080/fedora/risearch?type=tuples&amp;lang=itql&amp;format=Sparql&amp;query=select%20%24parentUri%20from%20%3C%23ri%3E%20%0Awhere%20%3Cinfo%3Afedora%2F</xsl:text>
            <xsl:value-of select="$pid" />
            <xsl:text>%3E%20%3Cinfo%3Afedora%2Ffedora-system%3Adef%2Frelations-external%23isPartOf%3E%20%24parentUri</xsl:text>
        </xsl:variable>
        <xsl:if test="$debug">
            <xsl:comment>
                Querying for related metadata from pid  <xsl:value-of select="$pid" /> using query: <xsl:value-of select="$lookupParentUri" />
            </xsl:comment>
        </xsl:if>
        <xsl:variable name="sparqlResult" select="document($lookupParentUri)" />
        <xsl:variable name="parentPid" select="substring($sparqlResult/s:sparql/s:results/s:result/s:parentUri/@uri, 13)"/>
        <xsl:if test="$parentPid">
            
            <xsl:call-template name="get-ancestry">
                <xsl:with-param name="pid" select="$parentPid"/>
            </xsl:call-template>
            
            <xsl:if test="$debug">
                <xsl:comment>Pulling metadata from <xsl:value-of select="$parentPid" /></xsl:comment>
            </xsl:if>
            <xsl:variable name="parentMetadataUrl">
                <xsl:text>http://</xsl:text><xsl:value-of select="$fedora-host" /><xsl:text>:8080/fedora/objects/</xsl:text>
                <xsl:value-of select="$parentPid" />
                <xsl:text>/methods/uva-lib:descMetadataSDef/getMetadataAsEADFragment</xsl:text>
            </xsl:variable>
            <xsl:variable name="parentDescMetadata" select="document($parentMetadataUrl)" />
            
            <ancestor>
                <pid><xsl:value-of select="$parentPid" /></pid>
                <xmlcontent>
                    <xsl:copy-of select="$parentDescMetadata" />
                </xmlcontent>
            </ancestor>
        </xsl:if>
    </xsl:template>


    <xsl:template name="index-ancestors">
        <xsl:param name="ancestors" required="yes" />
        
        <xsl:for-each select="$ancestors/ancestor">
            <xsl:variable name="pid" select="pid" />
            <xsl:apply-templates select="current()/xmlcontent//*" mode="subsequent" />
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="index-marc">
        <xsl:param name="pid" required="yes" />
        <xsl:param name="mode" required="yes" />
        
        <!-- check for marc record and index them as well -->
        <xsl:variable name="lookupMarcUri">
            <xsl:text>http://</xsl:text><xsl:value-of select="$fedora-host"></xsl:value-of><xsl:text>:8080/fedora/risearch?type=tuples&amp;lang=itql&amp;format=Sparql&amp;query=select%20%24marcUri%20from%20%3C%23ri%3E%20where%20%3Cinfo%3Afedora%2F</xsl:text>
            <xsl:value-of select="$pid"/>
            <xsl:text>%3E%20%3Chttp%3A%2F%2Ffedora.lib.virginia.edu%2Frelationships%23hasCatalogRecordIn%3E%20%24marcUri%0A</xsl:text>
        </xsl:variable>
        <xsl:if test="$debug">
            <xsl:comment>
                Querying for related MARC metadata from pid  <xsl:value-of select="$pid" /> using query: <xsl:value-of select="$lookupMarcUri" />
            </xsl:comment>
        </xsl:if>
        <xsl:variable name="marcSparqlResult" select="document($lookupMarcUri)" />
        <xsl:for-each select="$marcSparqlResult/s:sparql/s:results/s:result/s:marcUri/@uri">
            <xsl:variable name="marcPid" select="substring(current(), 13)" />
            <xsl:if test="$debug">
                <xsl:comment>Pulling MARC metadata from <xsl:value-of select="$marcPid" /></xsl:comment>
            </xsl:if>
            <xsl:variable name="marcMetadataUrl">
                <xsl:text>http://</xsl:text><xsl:value-of select="$fedora-host" /><xsl:text>:8080/fedora/objects/</xsl:text>
                <xsl:value-of select="$marcPid" />
                <xsl:text>/datastreams/descMetadata/content</xsl:text>
            </xsl:variable>
            <xsl:variable name="parentMarcMetadata" select="document($marcMetadataUrl)" />
            
            <xsl:comment><xsl:text>Applying templates in mode </xsl:text><xsl:value-of select="$mode"></xsl:value-of></xsl:comment>
            <xsl:if test="$mode = 'primary'">
                <xsl:apply-templates select="$parentMarcMetadata//*" mode="primary" />
            </xsl:if>
            <xsl:if test="$mode = 'subsequent'">
                <xsl:apply-templates select="$parentMarcMetadata//*" mode="subsequent" />
            </xsl:if>
            
        </xsl:for-each>
        
    </xsl:template>

    <doc:doc>
        <doc:desc>
            <doc:p>
                This method is recursive, and checks each level of the hierarchy (from
                most narrow to most broad) for references to containers in which this
                item is present.  At the first level in which any container is found, 
                the barcode values of all containers referenced at that level are included
                in the solr document.  The presence of more than one value implies in this
                case, not that multiple copies exist, but that there may be uncertainty
                about which of the referenced barcods contains the item, or that the 
                component spans multiple containers.
            </doc:p>
            <doc:ul>
                <doc:li mapping:type="solrField" mapping:sourceXPath="[the metadata records for each container that likely contains this item or component]">container_metadata_display</doc:li>
            </doc:ul>
        </doc:desc>
    </doc:doc>
    <xsl:template name="index-containers">
        <xsl:param name="pid" required="yes" />
        <xsl:param name="ancestry"/>
        <xsl:param name="index" select="count($ancestry/node())" />

        <xsl:variable name="current">
            <xsl:call-template name="index-container">
                <xsl:with-param name="pid" select="$pid" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:copy-of select="$current" />
        <xsl:if test="string-length($current/text()) = 0">
            <xsl:if test="$index &gt; 0">
                <xsl:call-template name="index-containers">
                    <xsl:with-param name="pid" select="$ancestry/ancestor[$index - 1]/pid" />
                    <xsl:with-param name="ancestry" select="$ancestry" />
                    <xsl:with-param name="index" select="$index - 1" />
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="index-container">
        <xsl:param name="pid" required="yes" />
        <xsl:variable name="lookupContainerUri">
            <xsl:text>http://</xsl:text><xsl:value-of select="$fedora-host" /><xsl:text>:8080/fedora/risearch?type=tuples&amp;lang=itql&amp;format=Sparql&amp;query=select%20%24containerUri%20from%20%3C%23ri%3E%20%0Awhere%20%3Cinfo%3Afedora%2F</xsl:text>
            <xsl:value-of select="$pid" />
            <xsl:text>%3E%20%3Chttp%3A%2F%2Ffedora.lib.virginia.edu%2Frelationships%23isContainedWithin%3E%20%24containerUri</xsl:text>
        </xsl:variable>
        <xsl:if test="$debug">
            <xsl:comment>Searching for containers that contain <xsl:value-of select="$pid" />...</xsl:comment>
        </xsl:if>
        <xsl:variable name="sparqlResult" select="document($lookupContainerUri)" />
        <xsl:variable name="containerUris" select="$sparqlResult/s:sparql/s:results/s:result/s:containerUri"/>
        <xsl:if test="$containerUris">
            <xsl:variable name="containerMap">
                <xsl:for-each select="$containerUris">
                    <xsl:variable name="containerPid" select="substring(current()/@uri, 13)" />
                    <xsl:variable name="metadata" select="document(concat('http://', $fedora-host, ':8080/fedora/objects/',$containerPid, '/datastreams/descMetadata/content'))" />
                    <container>
                        <catalogKey><xsl:value-of select="$metadata/container/catalogKey" /></catalogKey>
                        <barcode><xsl:value-of select="$metadata/container/barCode" /></barcode>
                    </container>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="keys" select="$containerMap//container[not(catalogKey=following::catalogKey)]" />
            <xsl:text>&lt;records&gt;</xsl:text>
                <xsl:for-each select="$keys">
                    <xsl:text>&lt;marc&gt;</xsl:text>
                    <xsl:text>&lt;catalogKey&gt;</xsl:text>
                    <xsl:value-of select="current()//catalogKey" />
                    <xsl:text>&lt;/catalogKey&gt;</xsl:text>
                    <xsl:for-each select="$containerMap//container[catalogKey=current()/catalogKey]/barcode">
                        <xsl:text>&lt;barcode&gt;</xsl:text>
                        <xsl:value-of select="current()" />
                        <xsl:text>&lt;/barcode&gt;</xsl:text>
                        </xsl:for-each>
                    <xsl:text>&lt;/marc&gt;</xsl:text>
                </xsl:for-each>
            <xsl:text>&lt;/records&gt;</xsl:text>
        </xsl:if>
    </xsl:template>
    
    <!-- Performs a fedora resource index query that will return the object uri of the 
        digital representation of the provided item if a digitized version
        exists for that item. 
    -->
    <xsl:template name="lookupDigitizedObject">
        <xsl:param name="itemPid" required="yes" />
        <xsl:variable name="lookupObject">
            <xsl:text>http://</xsl:text><xsl:value-of select="$fedora-host" /><xsl:text>:8080/fedora/risearch?type=tuples&amp;lang=itql&amp;format=Sparql&amp;query=select%20%24real%20from%20%3C%23ri%3E%20where%20%3Cinfo%3Afedora%2F</xsl:text>
            <xsl:value-of select="$itemPid" />
            <xsl:text>%3E%20%3Chttp%3A%2F%2Ffedora.lib.virginia.edu%2Frelationships%23isPlaceholderFor%3E%20%24real</xsl:text>
        </xsl:variable>
        <xsl:if test="$debug">
            <xsl:message terminate="no">
                Querying for the digitized version of <xsl:value-of select="$itemPid" /> using query: <xsl:value-of select="$lookupObject" />
            </xsl:message>
        </xsl:if>
        <xsl:variable name="result" select="document($lookupObject)/s:sparql/s:results/s:result/s:real/@uri" />
        <xsl:if test="not($result)">
            <xsl:variable name="exemplar">
                <xsl:call-template name="lookupDigitizedExemplar">
                    <xsl:with-param name="itemPid" select="$itemPid" />
                </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$exemplar != ''">
                <xsl:value-of select="concat('info:fedora/', $exemplar)" />
            </xsl:if>
        </xsl:if>
        <xsl:if test="$result">
            <xsl:value-of select="$result" />
        </xsl:if>
    </xsl:template>
    
    <!-- Performs a fedora resource index query that will return the object uri of the 
        exemplar (digital representation) of the provided item if a digitized version
        exists for that item.
        
        This template isn't currently used.
    -->
    <xsl:template name="lookupDigitizedExemplar">
        <xsl:param name="itemPid" required="yes" />
        <xsl:variable name="lookupExemplars">
            <xsl:text>http://</xsl:text><xsl:value-of select="$fedora-host" /><xsl:text>:8080/fedora/risearch?type=tuples&amp;lang=itql&amp;format=Sparql&amp;query=select%20%24exemplar%20from%20%3C%23ri%3E%20where%20%3Cinfo%3Afedora%2F</xsl:text>
            <xsl:value-of select="$itemPid" />
            <xsl:text>%3E%20%3Chttp%3A%2F%2Ffedora.lib.virginia.edu%2Frelationships%23hasExemplar%3E%20%24exemplar</xsl:text>
        </xsl:variable>
        <xsl:if test="$debug">
            <xsl:message terminate="no">
                Querying for the exemplar digitized version of <xsl:value-of select="$itemPid" /> using query: <xsl:value-of select="$lookupExemplars" />
            </xsl:message>
        </xsl:if>
        <xsl:value-of select="substring(document($lookupExemplars)/s:sparql/s:results/s:result/s:exemplar/@uri, 13)"></xsl:value-of>
    </xsl:template>
    
</xsl:stylesheet>