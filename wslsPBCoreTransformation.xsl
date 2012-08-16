<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:pbcore="http://www.pbcore.org/PBCore/PBCoreNamespace.html"
    xmlns:apia="http://www.fedora.info/definitions/1/0/access/"
    xmlns:doc="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mapping="http://lib.virginia.edu/mapping"
    exclude-result-prefixes="xs pbcore apia doc mapping"
    version="2.0">
    <!--
        Required solr fields for video display:
          format_facet = "Video"
          source_facet = "UVA Library Digital Repository"
          year_multisort_i (needed for sorting, must be four digits)
          date_received_facet (needed for sorting, must be 8 digits)
        
        Used to build index display (_index_partials/_dl_video.html.erb):
          (the title) 
            title_display
            medium_display = "electronic resource"
            subtitle_display (optional)
            date_coverage_display
          
          (thumbnails) 
          url_display ~= "http://www.kaltura.com/kwidget/wid/_419852/entry_id/1_pnz05jjn||Part one of two.","..."
          
          author_display (one value)
          author_facet
          author_sort_facet
          
          format_facet
          published_date_display
          
        Used to build full display (_show_partials/_dl_video.html.erb):
        
        DUPE format_facet = "Videos"
        !! Description came from marc... possibly we'll need to update this to come from a new field
        video_director_facet
        release_date_facet
        video_run_time_display (simple number, in minutes)
        DUPE url_display
        subject_facet
    -->
    
    <xsl:output byte-order-mark="no" encoding="UTF-8" media-type="text/xml" xml:space="preserve" indent="yes"/>
    
    <!-- required -->
    <xsl:param name="pid" />
    
    <!-- Must be the URL for the fedora repository in which the object resides, 
        the port is assumed to be 8080 and the context name "fedora" -->
    <xsl:variable name="fedora-host">localhost</xsl:variable>
    
    <doc:doc>
        <doc:desc>
            <doc:p>
                This matches the root of the PBCore document and outputs a corresponding SOLR add document.
                This transformation was written for the WSLS Collection and makes assumptions
                about the structure of the incoming PBCore document that may be unsuitable for 
                other materials.
            </doc:p>
            <doc:p>
                The following solr fields are automatically populated:
                <doc:ul>
                    <doc:li mapping:type="solrField" mapping:sourceXPath="$pid">id</doc:li>
                    <doc:li mapping:type="solrField" mapping:sourceXPath="'[the content smodel of the objects in fedora]'">content_model_facet</doc:li>
                    <doc:li mapping:type="solrField" mapping:sourceXPath="'Video', 'Online'">format_facet</doc:li>
                    <doc:li mapping:type="solrField" mapping:sourceXPath="'UVA Library Digital Repository'">source_facet</doc:li>
                    <doc:li mapping:type="solrField" mapping:sourceXPath="TBD - the Kaltura URL">url_display</doc:li>
                    <doc:li mapping:type="solrField" mapping:sourceXPath="TBD">digital_collection_facet</doc:li>
                    <doc:li mapping:type="solrField" mapping:sourceXPath="The date the item was first ingested into the repository">date_received_facet</doc:li>
                </doc:ul>
            </doc:p>
        </doc:desc>
    </doc:doc>
    <xsl:template match="/">
        <add>
            <doc>
                <field name="id"><xsl:value-of select="$pid"/></field>
                <field name="format_facet">
                    <xsl:text>Video</xsl:text>
                </field>
                <field name="format_facet">
                    <xsl:text>Online</xsl:text>
                </field>
                <field name="source_facet">
                    <xsl:text>UVA Library Digital Repository</xsl:text>
                </field>
                <field name="medium_display">
                    <xsl:text>electronic resource</xsl:text>
                </field>
                <!--  TODO: this needs to be provided
                <field name="url_display">
                </field>
                -->
                <field name="digital_collection_facet">
                    <xsl:text>WSLS-TV News Film Collection, 1951 to 1971</xsl:text>
                </field>
                
                <!-- Pull the required "date_received_facet" from fedora --> 
                <xsl:variable name="objectProfile" select="document(concat('http://', $fedora-host, ':8080/fedora/objects/', $pid, '?format=xml'))" />
                <xsl:variable name="createDate" select="$objectProfile/apia:objectProfile/apia:objCreateDate/text()" />
                <field name="date_received_facet">
                    <xsl:value-of select="concat(substring($createDate, 1, 4), substring($createDate, 6, 2), substring($createDate, 9, 2))" />
                </field> 
                
                <xsl:apply-templates select="pbcore:pbcoreDescriptionDocument//*" />
            </doc>
        </add>
    </xsl:template>
    
    <xsl:template match="*" priority="-1" />
    
    <doc:doc>
        <doc:desc>
            <doc:ul>
                <doc:li mapping:type="solrField">title_display</doc:li>
                <doc:li mapping:type="solrField">title_text</doc:li>
            </doc:ul>
        </doc:desc>
    </doc:doc>
    <xsl:template match="pbcore:pbcoreTitle">
        <field name="title_display"><xsl:value-of select="text()" /></field>
        <field name="title_text"><xsl:value-of select="text()" /></field>
    </xsl:template>
    
    <doc:doc>
        <doc:desc>
            <doc:ul>
                <doc:li mapping:type="solrField">date_coverage_display</doc:li>
                <doc:li mapping:type="solrField">date_coverage_text</doc:li>
                <doc:li mapping:type="solrField">published_date_display</doc:li>
                <doc:li mapping:type="solrField">year_multisort_i</doc:li>
            </doc:ul>
        </doc:desc>
    </doc:doc>
    <xsl:template match="pbcore:pbcoreAssetDate">
        <field name="date_coverage_display"><xsl:value-of select="text()" /></field>
        <field name="date_coverage_text"><xsl:value-of select="text()" /></field>
        <field name="published_date_display"><xsl:value-of select="text()" /></field>
        <field name="year_multisort_i">
            <xsl:value-of select="substring(text(), 7, 4)" />
        </field>
    </xsl:template>
    
    <doc:doc>
        <doc:desc>
            <doc:ul>
                <doc:li mapping:type="solrField">video_runtime_display</doc:li>
            </doc:ul>
        </doc:desc>
    </doc:doc>
    <xsl:template match="pbcore:pbcoreInstantiation[1]/pbcore:instantiationEssenceTrack/pbcore:essenceTrackAnnotation[@annotationType='Source_Duration_String']">
        <field name="video_run_time_display">
            <xsl:value-of select="text()" />
        </field>
    </xsl:template>

    <doc:doc>
        <doc:desc>
            <doc:ul>
                <doc:li mapping:type="solrField">subject_facet</doc:li>
            </doc:ul>
        </doc:desc>
    </doc:doc>
    <xsl:template match="pbcore:pbcoreSubject[@subjectType='Topic']">
        <field name="subject_facet">
            <xsl:value-of select="text()" />
        </field>
    </xsl:template>
    
    <doc:doc>
        <doc:desc>
            <doc:ul>
                <doc:li mapping:type="solrField">abstract_display</doc:li>
                <doc:li mapping:type="solrField">abstract_text</doc:li>
            </doc:ul>
        </doc:desc>
    </doc:doc>
    <xsl:template match="pbcore:pbcoreDescription[@descriptionType='abstract']">
        <field name="abstract_display">
            <xsl:value-of select="text()" />
        </field>
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
            <xsl:value-of select="text()" />
        </field>
    </xsl:template>
    
</xsl:stylesheet>