<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output byte-order-mark="no" encoding="UTF-8" media-type="text/xml" xml:space="default"
        indent="yes"/>

    <xsl:output method="xml" indent="yes" name="xml"/>

    <xsl:template match="/">
        <mods>
            <xsl:for-each select="/gdms/div/divdesc/title[@type='Constructed']">
                <xsl:element name="titleInfo">
                    <xsl:element name="title">
                        <xsl:value-of select="./text()"/>
                    </xsl:element>
                </xsl:element>
            </xsl:for-each>
           
            <!-- creates <name> and subelements -->

            <xsl:element name="name">
                <xsl:attribute name="authority">naf</xsl:attribute>
                <xsl:attribute name="type">personal</xsl:attribute>
                <xsl:element name="namePart">
                    <xsl:value-of>Davis, Jackson, 1882-1947</xsl:value-of>
                </xsl:element>
                <xsl:element name="role">
                    <xsl:element name="roleTerm">
                        <xsl:attribute name="type">
                            <xsl:value-of>text</xsl:value-of>
                        </xsl:attribute>
                        <xsl:value-of>photographer</xsl:value-of>
                    </xsl:element>
                    <xsl:element name="roleTerm">
                        <xsl:attribute name="type">
                            <xsl:value-of>code</xsl:value-of>
                        </xsl:attribute>
                        <xsl:attribute name="authority">
                            <xsl:value-of>marcrelator</xsl:value-of>
                        </xsl:attribute>
                        <xsl:value-of>pht</xsl:value-of>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            
            <!-- creates <typeOfResource> -->

            <xsl:element name="typeOfResource">
                <xsl:attribute name="collection">
                    <xsl:value-of>yes</xsl:value-of>
                </xsl:attribute>
                <xsl:value-of>still image</xsl:value-of>
            </xsl:element>
            
            <!-- creates <genre> -->
            
            <xsl:element name="genre">
                <xsl:attribute name="authority">
                    <xsl:value-of>aat</xsl:value-of>
                </xsl:attribute>
                <xsl:value-of>black-and-white photographs</xsl:value-of>
            </xsl:element>
            
            <!-- creates <originInfo> and subelements -->

            <xsl:element name="originInfo">
                <xsl:element name="place">
                    <xsl:element name="placeTerm">
                        <xsl:attribute name="type">
                            <xsl:value-of>code</xsl:value-of>
                        </xsl:attribute>
                        <xsl:attribute name="authority">
                            <xsl:value-of>marccountry</xsl:value-of>
                        </xsl:attribute>
                        <xsl:value-of>xxu</xsl:value-of>
                    </xsl:element>
                    <xsl:element name="placeTerm">
                        <xsl:attribute name="type">
                            <xsl:value-of>text</xsl:value-of>
                        </xsl:attribute>
                        <xsl:value-of>United States</xsl:value-of>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="dateCreated">
                    <xsl:attribute name="encoding">
                        <xsl:value-of>w3cdtf</xsl:value-of>
                    </xsl:attribute>
                    <xsl:attribute name="point">
                        <xsl:value-of>start</xsl:value-of>
                    </xsl:attribute>
                    <xsl:attribute name="keyDate">
                        <xsl:value-of>yes</xsl:value-of>
                    </xsl:attribute>
                    <xsl:value-of select="(gdms/div/divdesc/time/date[@type='begin'])[1]/text()"/>
                </xsl:element>
                <xsl:element name="dateCreated">
                    <xsl:attribute name="encoding">
                        <xsl:value-of>w3cdtf</xsl:value-of>
                    </xsl:attribute>
                    <xsl:attribute name="point">
                        <xsl:value-of>end</xsl:value-of>
                    </xsl:attribute>
                    <xsl:value-of select="(gdms/div/divdesc/time/date[@type='end'])[1]/text()"/>
                </xsl:element>
            </xsl:element>
            
            <!-- creates <physicalDescription> and subelements -->

            <xsl:element name="physicalDescription">
                <xsl:element name="form">
                    <xsl:attribute name="authority">
                        <xsl:value-of select="gdms/div/divdesc/mediatype/form/authority/text()"/>
                    </xsl:attribute>
                    <xsl:value-of select="gdms/div/divdesc/mediatype/form/text()"/>
                </xsl:element>
                <xsl:for-each select="gdms/div/divdesc/description[@type='technique']">
                    <xsl:element name="form">
                        <xsl:attribute name="type">
                            <xsl:value-of>technique</xsl:value-of>
                        </xsl:attribute>
                        <xsl:value-of select="./text()"/>
                    </xsl:element>
                </xsl:for-each>
                <xsl:element name="internetMediaType">
                    <xsl:value-of>image/tiff</xsl:value-of>
                </xsl:element>
                <xsl:element name="extent">
                    <xsl:value-of select="gdms/div/divdesc/physdesc[@type='extent']"/>
                </xsl:element>
                <xsl:element name="digitalOrigin">
                    <xsl:value-of>reformatted digital</xsl:value-of>
                </xsl:element>
            </xsl:element>
            
            <!-- creates <abstract> -->
            
            <xsl:element name="abstract">
                <xsl:value-of select="gdms/div/resgrp/res/description[@type='view']/text()"/>
            </xsl:element>
            
            <!-- creates <subject> -->
            
            <xsl:for-each select="gdms/div/divdesc/subject">
               <xsl:element name="subject">
                   <xsl:if test=".[@scheme]">
                   <xsl:attribute name="authority">
                       <xsl:value-of select="./@scheme"/>
                   </xsl:attribute>
                   </xsl:if>
                   <xsl:choose>
                       <xsl:when test="not(contains(./text(),' -- '))">
                           <xsl:element name="topic">
                               <xsl:value-of select="./text()"/>
                           </xsl:element>
                       </xsl:when>
                       <xsl:when test="./text(),' -- '">
                           <xsl:element name="topic">
                               <xsl:value-of select="substring-before(./text(),' -- ')"/>
                           </xsl:element>
                           <xsl:element name="topic">
                               <xsl:value-of select="substring-after(./text(),' -- ')"/>
                           </xsl:element>
                       </xsl:when>
                   </xsl:choose>
               </xsl:element>  
            </xsl:for-each>
            
            <!-- creates <relatedItem> for Jackson Davis Collection-->
            
            <xsl:element name="relatedItem">
                <xsl:attribute name="type">
                    <xsl:value-of>series</xsl:value-of>
                </xsl:attribute>
                <xsl:attribute name="displayLabel">
                    <xsl:value-of>Part of</xsl:value-of>
                </xsl:attribute>
                <xsl:element name="titleInfo">
                    <xsl:element name="title">
                        <xsl:value-of>The Jackson Davis Collection of African American Photographs</xsl:value-of>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="name">
                    <xsl:attribute name="authority">naf</xsl:attribute>
                    <xsl:attribute name="type">personal</xsl:attribute>
                    <xsl:element name="namePart">
                        <xsl:value-of>Davis, Jackson, 1882-1947</xsl:value-of>
                    </xsl:element> 
                </xsl:element>
            </xsl:element>
            
            <!-- creates <relatedItem> for Papers and Photographs of Jackson Davis -->
            
            <xsl:element name="relatedItem">
                <xsl:attribute name="type">
                    <xsl:value-of>host</xsl:value-of>
                </xsl:attribute>
                <xsl:attribute name="displayLabel">
                    <xsl:value-of>Digitized from</xsl:value-of>
                </xsl:attribute>
                <xsl:element name="titleInfo">
                    <xsl:element name="title">
                        <xsl:value-of>Papers and photographs of Jackson Davis [manuscript] 1906-1947 and n.d.</xsl:value-of>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="name">
                    <xsl:attribute name="authority">naf</xsl:attribute>
                    <xsl:attribute name="type">personal</xsl:attribute>
                    <xsl:element name="namePart">
                        <xsl:value-of>Davis, Jackson, 1882-1947</xsl:value-of>
                    </xsl:element> 
                </xsl:element>
                <xsl:element name="originInfo">
                    <xsl:element name="dateCreated">
                        <xsl:attribute name="encoding">
                            <xsl:value-of>w3cdtf</xsl:value-of>
                        </xsl:attribute>
                        <xsl:attribute name="keyDate">
                            <xsl:value-of>yes</xsl:value-of>
                        </xsl:attribute>
                        <xsl:attribute name="point">
                            <xsl:value-of>begin</xsl:value-of>
                        </xsl:attribute>
                        <xsl:value-of>1906</xsl:value-of>
                    </xsl:element>
                    <xsl:element name="dateCreated">
                        <xsl:attribute name="encoding">
                            <xsl:value-of>w3cdtf</xsl:value-of>
                        </xsl:attribute>
                        <xsl:attribute name="point">
                            <xsl:value-of>end</xsl:value-of>
                        </xsl:attribute>
                        <xsl:value-of>1947</xsl:value-of>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="identifier">
                    <xsl:attribute name="type">
                        <xsl:value-of>local</xsl:value-of>
                    </xsl:attribute>
                    <xsl:value-of>MSS 3072, 3072-a</xsl:value-of>
                </xsl:element>
                <xsl:element name="identifier">
                    <xsl:attribute name="type">
                        <xsl:value-of>uri</xsl:value-of>
                    </xsl:attribute>
                    <xsl:value-of>http://search.lib.virginia.edu/catalog/u2884151</xsl:value-of>
                </xsl:element>
            </xsl:element>
            
            <!-- creates <identifier> for collection accession number -->
            
            <xsl:element name="identifier">
                <xsl:attribute name="type">
                    <xsl:value-of>accessionNumber</xsl:value-of>
                </xsl:attribute>
                <xsl:attribute name="displayLabel">
                    <xsl:value-of>Collection Accession Number</xsl:value-of>
                </xsl:attribute>
                <xsl:value-of>MSS 3072, 3072-a</xsl:value-of>
            </xsl:element>
 
        </mods>
    </xsl:template>
</xsl:stylesheet>
