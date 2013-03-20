<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:pbcore="http://www.pbcore.org/PBCore/PBCoreNamespace.html"
  xmlns:apia="http://www.fedora.info/definitions/1/0/access/"
  xmlns:doc="http://www.oxygenxml.com/ns/doc/xsl" xmlns:mapping="http://lib.virginia.edu/mapping"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:uva-rels="http://fedora.lib.virginia.edu/relationships#"
  xmlns:s="http://www.w3.org/2001/sw/DataAccess/rf1/result"
  exclude-result-prefixes="xs pbcore apia doc mapping s rdf uva-rels" version="2.0">

  <xsl:output byte-order-mark="no" encoding="UTF-8" media-type="text/xml" xml:space="preserve" indent="yes" />

  <!-- required -->
  <xsl:param name="pid" />

  <xsl:param name="debug" />

  <!-- Must be the URL for the fedora repository in which the object resides, 
        the port is assumed to be 8080 and the context name "fedora" -->
  <xsl:param name="fedora-host">localhost</xsl:param>

  <!-- Must be the fedora url used for public access requests to the content. -->
  <xsl:param name="fedora-proxy-url">http://fedoraproxy.lib.virginia.edu/fedora/</xsl:param>

  <doc:doc>
    <doc:desc>
      <doc:p> This matches the root of the PBCore document and outputs a corresponding SOLR add
        document. This transformation was written for the WSLS Collection and makes assumptions
        about the structure of the incoming PBCore document that may be unsuitable for other
        materials. </doc:p>
      <doc:p> The following solr fields are automatically populated: <doc:ul>
          <doc:li mapping:type="solrField" mapping:sourceXPath="$pid">id</doc:li>
          <doc:li mapping:type="solrField"
            mapping:sourceXPath="'[the content smodel of the objects in fedora]'"
            >content_model_facet</doc:li>
          <doc:li mapping:type="solrField" mapping:sourceXPath="'Video', 'Online'"
            >format_facet</doc:li>
          <doc:li mapping:type="solrField" mapping:sourceXPath="'Digital Library'"
            >source_facet</doc:li>
          <doc:li mapping:type="solrField" mapping:sourceXPath="[the Kaltura URL]"
            >url_display</doc:li>
          <doc:li mapping:type="solrField"
            mapping:sourceXPath="The date the item was first ingested into the repository"
            >date_received_facet</doc:li>
          <doc:li mapping:type="solrField" mapping:sourceXPath="[the entire pbcore record]"
            >pbcore_display</doc:li>
        </doc:ul>
      </doc:p>
    </doc:desc>
  </doc:doc>
  <xsl:template match="/">
    <add>
      <doc>
        <field name="id">
          <xsl:value-of select="$pid" />
        </field>
        <field name="format_facet">
          <xsl:text>Video</xsl:text>
        </field>
        <field name="format_facet">
          <xsl:text>Online</xsl:text>
        </field>
        <field name="source_facet">
          <xsl:text>Digital Library</xsl:text>
        </field>

        <!-- Pull the required "date_received_facet" from fedora as well as the content models -->
        <xsl:variable name="objectProfile"
          select="document(concat('http://', $fedora-host, ':8080/fedora/objects/', $pid, '?format=xml'))" />
        <xsl:variable name="createDate"
          select="$objectProfile/apia:objectProfile/apia:objCreateDate/text()" />
        <field name="date_received_facet">
          <xsl:value-of
            select="concat(substring($createDate, 1, 4), substring($createDate, 6, 2), substring($createDate, 9, 2))"
           />
        </field>
        <xsl:for-each select="$objectProfile/apia:objectProfile/apia:objModels/apia:model">
          <xsl:if test="not(starts-with(current(), 'info:fedora/fedora-system'))">
            <field name="content_model_facet">
              <xsl:value-of select="substring(text(), string-length('info:fedora/') + 1)" />
            </field>
          </xsl:if>
        </xsl:for-each>

        <!-- Pull the script (if one's available) and index the full text -->
        <xsl:call-template name="lookupAnchorScript">
          <xsl:with-param name="itemPid" select="$pid" />
        </xsl:call-template>

        <xsl:apply-templates select="pbcore:pbcoreDescriptionDocument//*" />

        <xsl:variable name="relsExt"
          select="document(concat('http://', $fedora-host, ':8080/fedora/objects/', $pid, '/datastreams/RELS-EXT/content'))" />
        <xsl:variable name="visibility"
          select="$relsExt/rdf:RDF/rdf:Description/uva-rels:visibility" />
        <xsl:if test="not($visibility)">
          <field name="shadowed_location_facet">
            <xsl:text>VISIBLE</xsl:text>
          </field>
        </xsl:if>
        <xsl:if test="$visibility">
          <field name="shadowed_location_facet">
            <xsl:value-of select="$visibility" />
          </field>
        </xsl:if>

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
            <xsl:text>&lt;id&gt;</xsl:text>
            <xsl:value-of select="pid" />
            <xsl:text>&lt;/id&gt;</xsl:text>

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
        <xsl:variable name="summary"
          select="unparsed-text(concat('http://', $fedora-host, ':8080/fedora/objects/', $pid, '/methods/uva-lib:hierarchicalMetadataSDef/getSummary'))" />
        <field name="hierarchy_display">
          <xsl:value-of select="$summary" />
        </field>
        <field name="full_hierarchy_display">
          <!--
                  The full_hierarchy_display has been deprecated, but not yet removed from the VIRGO code or Solr DocumentHandler.
                  A single summary that contains every child of the current level and up to 3 children of each of those is sufficient
                  for all the UI needs.
                  <xsl:value-of select="unparsed-text(concat('http://', $fedora-host, ':8080/fedora/objects/', $pid, '/methods/uva-lib:hierarchicalMetadataSDef/getFullSummary'))" />
                -->
          <xsl:value-of select="$summary" />
        </field>

        <field name="pbcore_display">
          <xsl:value-of
            select="unparsed-text(concat('http://', $fedora-host, ':8080/fedora/objects/', $pid, '/datastreams/metadata/content'))"
           />
        </field>
      </doc>
    </add>
  </xsl:template>

  <xsl:template match="*" priority="-1" />
  <xsl:template match="*" priority="-1" mode="subsequent" />

  <doc:doc>
    <doc:desc>
      <doc:ul>
        <doc:li mapping:type="solrField">title_display</doc:li>
        <doc:li mapping:type="solrField">title_text</doc:li>
      </doc:ul>
    </doc:desc>
  </doc:doc>
  <xsl:template match="pbcore:pbcoreTitle">
    <field name="title_display">
      <xsl:value-of select="text()" />
    </field>
    <field name="title_text">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>

  <doc:doc>
    <doc:desc>
      <doc:ul>
        <doc:li mapping:type="solrField">date_coverage_display</doc:li>
        <doc:li mapping:type="solrField">date_coverage_text</doc:li>
        <doc:li mapping:type="solrField">published_date_display</doc:li>
        <doc:li mapping:type="solrField">year_multisort_i</doc:li>
        <doc:li mapping:type="solrField">published_date_facet</doc:li>
      </doc:ul>
    </doc:desc>
  </doc:doc>
  <xsl:template match="pbcore:pbcoreAssetDate">
    <field name="date_coverage_display">
      <xsl:value-of select="text()" />
    </field>
    <field name="date_coverage_text">
      <xsl:value-of select="text()" />
    </field>
    <field name="published_date_display">
      <xsl:value-of select="text()" />
    </field>
    <xsl:variable name="year"
      select="concat('19', substring-after(substring-after(text(), '/'), '/'))" />
    <field name="year_multisort_i">
      <xsl:value-of select="$year" />
    </field>
    <xsl:variable name="age"
      select="number(substring(string(current-date()), 1, 4)) - number($year)" />
    <xsl:if test="$age &lt;= 1">
      <field name="published_date_facet">
        <xsl:text>This year</xsl:text>
      </field>
    </xsl:if>
    <xsl:if test="$age &lt;= 3">
      <field name="published_date_facet">
        <xsl:text>Last 3 years</xsl:text>
      </field>
    </xsl:if>
    <xsl:if test="$age &lt;= 10">
      <field name="published_date_facet">
        <xsl:text>Last 10 years</xsl:text>
      </field>
    </xsl:if>
    <xsl:if test="$age &lt;= 50">
      <field name="published_date_facet">
        <xsl:text>Last 50 years</xsl:text>
      </field>
    </xsl:if>
    <xsl:if test="$age &gt; 50">
      <field name="published_date_facet">
        <xsl:text>More than 50 years ago</xsl:text>
      </field>
    </xsl:if>

  </xsl:template>

  <doc:doc>
    <doc:desc>
      <doc:ul>
        <doc:li mapping:type="solrField">url_display</doc:li>
      </doc:ul>
    </doc:desc>
  </doc:doc>
  <xsl:template match="pbcore:pbcoreInstantiation/pbcore:instantiationLocation">
    <field name="url_display">
      <xsl:value-of select="text()" />
    </field>
    <field name="format_facet">Streaming Video</field>
  </xsl:template>

  <doc:doc>
    <doc:desc>
      <doc:ul>
        <doc:li mapping:type="solrField">subject_facet</doc:li>
        <doc:li mapping:type="solrField">subject_text</doc:li>
      </doc:ul>
    </doc:desc>
  </doc:doc>
  <xsl:template match="pbcore:pbcoreSubject[@subjectType='Topic']">
    <field name="subject_facet">
      <xsl:value-of select="normalize-space(text())" />
    </field>
    <field name="subject_text">
      <xsl:value-of select="normalize-space(text())" />
    </field>
  </xsl:template>

  <doc:doc>
    <doc:desc>
      <doc:ul>
        <doc:li mapping:type="solrField">subject_facet</doc:li>
        <doc:li mapping:type="solrField">subject_text</doc:li>
      </doc:ul>
    </doc:desc>
  </doc:doc>
  <xsl:template match="pbcore:pbcoreSubject[@subjectType='Entity']">
    <field name="subject_facet">
      <xsl:value-of select="normalize-space(text())" />
    </field>
    <field name="subject_text">
      <xsl:value-of select="normalize-space(text())" />
    </field>
  </xsl:template>

  <doc:doc>
    <doc:desc>
      <doc:ul>
        <doc:li mapping:type="solrField">abstract_text</doc:li>
      </doc:ul>
    </doc:desc>
  </doc:doc>
  <xsl:template match="pbcore:pbcoreDescription[@descriptionType='abstract']">
    <field name="abstract_text">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>

  <doc:doc>
    <doc:desc>
      <doc:ul>
        <doc:li mapping:type="solrField">region_facet</doc:li>
      </doc:ul>
    </doc:desc>
  </doc:doc>
  <xsl:template match="pbcore:pbcoreSubject[@subjectType='Place']">
    <field name="region_facet">
      <xsl:value-of select="normalize-space(text())" />
    </field>
  </xsl:template>

  <!-- Performs a fedora resource index query that will identify the  
        anchor script for the clip described by this PBCore record.  This
        template will then output several fields associated with that
        script.
    -->
  <doc:doc>
    <doc:desc>
      <doc:ul>
        <doc:li mapping:type="solrField" mapping:sourceXPath="[anchor script pdf location]"
          >anchor_script_pdf_url_display</doc:li>
        <doc:li mapping:type="solrField" mapping:sourceXPath="[anchor script text location]"
          >anchor_script_text_url_display</doc:li>
        <doc:li mapping:type="solrField" mapping:sourceXPath="[anchor script thumbnail location]"
          >anchor_script_thumbnail_url_display</doc:li>
        <doc:li mapping:type="solrField" mapping:sourceXPath="[anchor script text]"
          >anchor_script_text</doc:li>
      </doc:ul>
    </doc:desc>
  </doc:doc>
  <xsl:template name="lookupAnchorScript">
    <xsl:param name="itemPid" required="yes" />
    <xsl:variable name="lookupScript">
      <xsl:text>http://</xsl:text>
      <xsl:value-of select="$fedora-host" />
      <xsl:text>:8080/fedora/risearch?type=tuples&amp;lang=itql&amp;format=Sparql&amp;query=select%20%24script%20from%20%3C%23ri%3E%20where%20%24script%20%3Chttp%3A%2F%2Ffedora.lib.virginia.edu%2Fwsls%2Frelationships%23isAnchorScriptFor%3E%20%3Cinfo%3Afedora%2F</xsl:text>
      <xsl:value-of select="$itemPid" />
      <xsl:text>%3E</xsl:text>
    </xsl:variable>
    <xsl:variable name="scriptUri"
      select="document($lookupScript)/s:sparql/s:results/s:result/s:script/@uri" />
    <xsl:if test="$scriptUri">
      <xsl:variable name="scriptPid"
        select="substring($scriptUri, string-length('info:fedora/') + 1)" />
      <field name="anchor_script_pdf_url_display">
        <xsl:value-of
          select="concat($fedora-proxy-url, 'objects/', $scriptPid, '/datastreams/scriptPDF/content')"
         />
      </field>
      <field name="anchor_script_thumbnail_url_display">
        <xsl:value-of
          select="concat($fedora-proxy-url, 'objects/', $scriptPid, '/datastreams/thumbnail/content')"
         />
      </field>
      <field name="anchor_script_text_url_display">
        <xsl:value-of
          select="concat($fedora-proxy-url, 'objects/', $scriptPid, '/datastreams/scriptTEXT/content')"
         />
      </field>
      <xsl:variable name="anchorScriptText"
        select="unparsed-text(concat('http://', $fedora-host, ':8080/fedora/objects/', $scriptPid, '/datastreams/scriptTXT/content'))" />
      <field name="anchor_script_text" boost="0.1">
        <xsl:value-of select="$anchorScriptText" />
      </field>
      <field name="anchor_script_display">
        <xsl:value-of select="$anchorScriptText" />
      </field>
      <field name="format_facet"><xsl:text>Anchor Script</xsl:text></field>
    </xsl:if>
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
      <xsl:text>http://</xsl:text>
      <xsl:value-of select="$fedora-host" />
      <xsl:text>:8080/fedora/risearch?type=tuples&amp;lang=itql&amp;format=Sparql&amp;query=select%20%24parentUri%20from%20%3C%23ri%3E%20%0Awhere%20%3Cinfo%3Afedora%2F</xsl:text>
      <xsl:value-of select="$pid" />
      <xsl:text>%3E%20%3Cinfo%3Afedora%2Ffedora-system%3Adef%2Frelations-external%23isPartOf%3E%20%24parentUri</xsl:text>
    </xsl:variable>
    <xsl:if test="$debug">
      <xsl:comment> Querying for related metadata from pid <xsl:value-of select="$pid" /> using
        query: <xsl:value-of select="$lookupParentUri" />
      </xsl:comment>
    </xsl:if>
    <xsl:variable name="sparqlResult" select="document($lookupParentUri)" />
    <xsl:variable name="parentPid"
      select="substring($sparqlResult/s:sparql/s:results/s:result/s:parentUri/@uri, 13)" />
    <xsl:if test="$parentPid">

      <xsl:call-template name="get-ancestry">
        <xsl:with-param name="pid" select="$parentPid" />
      </xsl:call-template>

      <xsl:if test="$debug">
        <xsl:comment>Pulling metadata from <xsl:value-of select="$parentPid" /></xsl:comment>
      </xsl:if>
      <xsl:variable name="parentMetadataUrl">
        <xsl:text>http://</xsl:text>
        <xsl:value-of select="$fedora-host" />
        <xsl:text>:8080/fedora/objects/</xsl:text>
        <xsl:value-of select="$parentPid" />
        <xsl:text>/methods/uva-lib:descMetadataSDef/getMetadataAsEADFragment</xsl:text>
      </xsl:variable>
      <xsl:variable name="parentDescMetadata" select="document($parentMetadataUrl)" />

      <ancestor>
        <pid>
          <xsl:value-of select="$parentPid" />
        </pid>
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
      <xsl:text>http://</xsl:text>
      <xsl:value-of select="$fedora-host" />
      <xsl:text>:8080/fedora/risearch?type=tuples&amp;lang=itql&amp;format=Sparql&amp;query=select%20%24marcUri%20from%20%3C%23ri%3E%20where%20%3Cinfo%3Afedora%2F</xsl:text>
      <xsl:value-of select="$pid" />
      <xsl:text>%3E%20%3Chttp%3A%2F%2Ffedora.lib.virginia.edu%2Frelationships%23hasCatalogRecordIn%3E%20%24marcUri%0A</xsl:text>
    </xsl:variable>
    <xsl:if test="$debug">
      <xsl:comment> Querying for related MARC metadata from pid <xsl:value-of select="$pid" /> using
        query: <xsl:value-of select="$lookupMarcUri" />
      </xsl:comment>
    </xsl:if>
    <xsl:variable name="marcSparqlResult" select="document($lookupMarcUri)" />
    <xsl:for-each select="$marcSparqlResult/s:sparql/s:results/s:result/s:marcUri/@uri">
      <xsl:variable name="marcPid" select="substring(current(), 13)" />
      <xsl:if test="$debug">
        <xsl:comment>Pulling MARC metadata from <xsl:value-of select="$marcPid" /></xsl:comment>
      </xsl:if>
      <xsl:variable name="marcMetadataUrl">
        <xsl:text>http://</xsl:text>
        <xsl:value-of select="$fedora-host" />
        <xsl:text>:8080/fedora/objects/</xsl:text>
        <xsl:value-of select="$marcPid" />
        <xsl:text>/datastreams/descMetadata/content</xsl:text>
      </xsl:variable>
      <xsl:variable name="parentMarcMetadata" select="document($marcMetadataUrl)" />

      <xsl:comment>
        <xsl:text>Applying templates in mode </xsl:text>
        <xsl:value-of select="$mode" />
      </xsl:comment>
      <xsl:if test="$mode = 'primary'">
        <xsl:apply-templates select="$parentMarcMetadata//*" mode="primary" />
      </xsl:if>
      <xsl:if test="$mode = 'subsequent'">
        <xsl:apply-templates select="$parentMarcMetadata//*" mode="subsequent" />
      </xsl:if>

    </xsl:for-each>

  </xsl:template>

  <xsl:template match="ead" mode="subsequent">
    <xsl:if test="@id">
      <field name="ead_id_text" boost="0.25">
        <xsl:value-of select="@id" />
      </field>
    </xsl:if>
    <xsl:if test="$debug">
      <xsl:comment>Matched EAD</xsl:comment>
    </xsl:if>
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
    <field name="collection_title_display">
      <xsl:value-of select="normalize-space($title)" />
    </field>
    <field name="digital_collection_facet">
      <xsl:value-of select="normalize-space($title)" />
    </field>
    <field name="collection_title_text" boost="0.25">
      <xsl:value-of select="normalize-space($title)" />
    </field>
  </xsl:template>

</xsl:stylesheet>
