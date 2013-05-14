<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:date="java:java.util.Date">
    <xsl:output byte-order-mark="no" encoding="UTF-8" media-type="text/xml" xml:space="default"
        indent="yes"/>
    <xsl:output method="xml" indent="yes" name="xml"/>

    <xsl:template match="/">
        <xsl:variable name="filename"
            select="concat(substring-after(gdms/gdmshead/gdmsid/system/text(),':'),'.mods','.xml')"/>
        <xsl:value-of select="$filename"/>
        <!-- Creating  -->
        <xsl:result-document href="{$filename}" format="xml">

            <mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd"
                xmlns:mods="http://www.loc.gov/mods/v3" xmlns="http://www.loc.gov/mods/v3">
                <xsl:for-each select="gdms/div/divdesc/title[@type='Constructed']">
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

                    <xsl:choose>
                        <xsl:when test="(gdms/div/divdesc/time/date[@type='January'])">
                            <xsl:element name="dateCreated">
                                <xsl:attribute name="keyDate">
                                    <xsl:value-of>yes</xsl:value-of>
                                </xsl:attribute>
                                <xsl:value-of select="concat(gdms/div[1]/divdesc[1]/time[1]/date[1]/text(),'-01')"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="(gdms/div/divdesc/time/date[@type='February'])">
                            <xsl:element name="dateCreated">
                                <xsl:attribute name="keyDate">
                                    <xsl:value-of>yes</xsl:value-of>
                                </xsl:attribute>
                                <xsl:value-of select="concat(gdms/div[1]/divdesc[1]/time[1]/date[1]/text(),'-02')"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="(gdms/div/divdesc/time/date[@type='March'])">
                            <xsl:element name="dateCreated">
                                <xsl:attribute name="keyDate">
                                    <xsl:value-of>yes</xsl:value-of>
                                </xsl:attribute>
                                <xsl:value-of select="concat(gdms/div[1]/divdesc[1]/time[1]/date[1]/text(),'-03')"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="(gdms/div/divdesc/time/date[@type='April'])">
                            <xsl:element name="dateCreated">
                                <xsl:attribute name="keyDate">
                                    <xsl:value-of>yes</xsl:value-of>
                                </xsl:attribute>
                                <xsl:value-of select="concat(gdms/div[1]/divdesc[1]/time[1]/date[1]/text(),'-04')"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="(gdms/div/divdesc/time/date[@type='May'])">
                            <xsl:element name="dateCreated">
                                <xsl:attribute name="keyDate">
                                    <xsl:value-of>yes</xsl:value-of>
                                </xsl:attribute>
                                <xsl:value-of select="concat(gdms/div[1]/divdesc[1]/time[1]/date[1]/text(),'-05')"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="(gdms/div/divdesc/time/date[@type='June'])">
                            <xsl:element name="dateCreated">
                                <xsl:attribute name="keyDate">
                                    <xsl:value-of>yes</xsl:value-of>
                                </xsl:attribute>
                                <xsl:value-of select="concat(gdms/div[1]/divdesc[1]/time[1]/date[1]/text(),'-06')"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="(gdms/div/divdesc/time/date[@type='July'])">
                            <xsl:element name="dateCreated">
                                <xsl:attribute name="keyDate">
                                    <xsl:value-of>yes</xsl:value-of>
                                </xsl:attribute>
                                <xsl:value-of select="concat(gdms/div[1]/divdesc[1]/time[1]/date[1]/text(),'-07')"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="(gdms/div/divdesc/time/date[@type='August'])">
                            <xsl:element name="dateCreated">
                                <xsl:attribute name="keyDate">
                                    <xsl:value-of>yes</xsl:value-of>
                                </xsl:attribute>
                                <xsl:value-of select="concat(gdms/div[1]/divdesc[1]/time[1]/date[1]/text(),'-08')"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="(gdms/div/divdesc/time/date[@type='September'])">
                            <xsl:element name="dateCreated">
                                <xsl:attribute name="keyDate">
                                    <xsl:value-of>yes</xsl:value-of>
                                </xsl:attribute>
                                <xsl:value-of select="concat(gdms/div[1]/divdesc[1]/time[1]/date[1]/text(),'-09')"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="(gdms/div/divdesc/time/date[@type='October'])">
                            <xsl:element name="dateCreated">
                                <xsl:attribute name="keyDate">
                                    <xsl:value-of>yes</xsl:value-of>
                                </xsl:attribute>
                                <xsl:value-of select="concat(gdms/div[1]/divdesc[1]/time[1]/date[1]/text(),'-10')"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="(gdms/div/divdesc/time/date[@type='November'])">
                            <xsl:element name="dateCreated">
                                <xsl:attribute name="keyDate">
                                    <xsl:value-of>yes</xsl:value-of>
                                </xsl:attribute>
                                <xsl:value-of select="concat(gdms/div[1]/divdesc[1]/time[1]/date[1]/text(),'-11')"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="(gdms/div/divdesc/time/date[@type='December'])">
                            <xsl:element name="dateCreated">
                                <xsl:attribute name="keyDate">
                                    <xsl:value-of>yes</xsl:value-of>
                                </xsl:attribute>
                                <xsl:value-of select="concat(gdms/div[1]/divdesc[1]/time[1]/date[1]/text(),'-12')"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="(gdms/div/divdesc/time/date[@type='begin'])">
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
                                <xsl:value-of
                                    select="(gdms/div/divdesc/time/date[@type='begin'])[1]/text()"/>
                            </xsl:element>
                            <xsl:element name="dateCreated">
                                <xsl:attribute name="encoding">
                                    <xsl:value-of>w3cdtf</xsl:value-of>
                                </xsl:attribute>
                                <xsl:attribute name="point">
                                    <xsl:value-of>end</xsl:value-of>
                                </xsl:attribute>
                                <xsl:value-of
                                    select="(gdms/div/divdesc/time/date[@type='end'])[1]/text()"/>
                            </xsl:element>
                        </xsl:when>
                        
                    </xsl:choose>

                </xsl:element>




                <!-- creates <physicalDescription> and subelements -->

                <xsl:element name="physicalDescription">
                    <xsl:element name="form">
                        <xsl:value-of select="gdms/div/divdesc/physdesc[@type='medium']/text()"/>
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

                <!-- creates <note> -->

                <xsl:for-each select="gdms/gdmshead/filedesc/setstmt/set/@code">
                    <xsl:element name="note">
                        <xsl:attribute name="type">
                            <xsl:value-of>staff</xsl:value-of>
                        </xsl:attribute>
                        <xsl:attribute name="displayLabel">
                            <xsl:value-of>legacy set code</xsl:value-of>
                        </xsl:attribute>
                        <xsl:value-of select="."/>
                    </xsl:element>
                </xsl:for-each>

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
                            <xsl:value-of>The Jackson Davis Collection of African American
                                Photographs</xsl:value-of>
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
                            <xsl:value-of>Papers and photographs of Jackson Davis [manuscript]
                                1906-1947 and n.d.</xsl:value-of>
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
                                <xsl:value-of>start</xsl:value-of>
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

                <!-- creates <identifier> for legacy FA number (1/2) -->

                <xsl:element name="identifier">
                    <xsl:attribute name="type">
                        <xsl:value-of>legacy</xsl:value-of>
                    </xsl:attribute>
                    <xsl:attribute name="displayLabel">
                        <xsl:value-of>UVa Fine Arts Identifier</xsl:value-of>
                    </xsl:attribute>
                    <xsl:value-of select="gdms/div/divdesc/identifier[@type='UVa Fine Arts']/text()"
                    />
                </xsl:element>

                <!-- creates <identifier> for legacy FA number (2/2) -->

                <xsl:element name="identifier">
                    <xsl:attribute name="type">
                        <xsl:value-of>legacy</xsl:value-of>
                    </xsl:attribute>
                    <xsl:attribute name="displayLabel">
                        <xsl:value-of>UVa Fine Arts Identifier</xsl:value-of>
                    </xsl:attribute>
                    <xsl:value-of
                        select="/gdms/div/resgrp/res/identifier[@type='UVa Fine Arts']/text()"/>
                </xsl:element>

                <!-- creates <identifier> for legacy negative number -->

                <xsl:element name="identifier">
                    <xsl:attribute name="type">
                        <xsl:value-of>legacy</xsl:value-of>
                    </xsl:attribute>
                    <xsl:attribute name="displayLabel">
                        <xsl:value-of>Negative Number</xsl:value-of>
                    </xsl:attribute>
                    <xsl:value-of
                        select="gdms/div/resgrp/res/identifier[@type='negative number']/text()"/>
                </xsl:element>

                <!-- creates <identifier> for image PID -->

                <xsl:element name="identifier">
                    <xsl:attribute name="type">
                        <xsl:value-of>legacy</xsl:value-of>
                    </xsl:attribute>
                    <xsl:attribute name="displayLabel">
                        <xsl:value-of>image PID</xsl:value-of>
                    </xsl:attribute>
                    <xsl:value-of select="gdms/div/resgrp/res/@id"/>
                </xsl:element>

                <!-- creates <identifier> for EAD ID -->

                <xsl:element name="identifier">
                    <xsl:attribute name="type">
                        <xsl:value-of>local</xsl:value-of>
                    </xsl:attribute>
                    <xsl:attribute name="displayLabel">
                        <xsl:value-of>UVa EAD ID</xsl:value-of>
                    </xsl:attribute>
                    <xsl:value-of
                        select="/gdms/div/resgrp/res/identifier[@type='UVa EAD ID']/text()"/>
                </xsl:element>

                <!-- creates <location> -->

                <xsl:element name="location">
                    <xsl:element name="physicalLocation">
                        <xsl:value-of>Special Collections, University of Virginia Library,
                            Charlottesville, Va.</xsl:value-of>
                    </xsl:element>
                    <xsl:element name="physicalLocation">
                        <xsl:attribute name="authority">
                            <xsl:value-of>oclcorg</xsl:value-of>
                        </xsl:attribute>
                        <xsl:value-of>VA@</xsl:value-of>
                    </xsl:element>
                    <xsl:element name="url">
                        <xsl:attribute name="usage">
                            <xsl:value-of>primary display</xsl:value-of>
                        </xsl:attribute>
                        <xsl:value-of
                            select="concat('http://search.lib.virginia.edu/catalog/',gdms/gdmshead/gdmsid/system)"
                        />
                    </xsl:element>
                </xsl:element>

                <!-- creates <accessCondition> -->

                <xsl:element name="accessCondition">
                    <xsl:attribute name="type">
                        <xsl:value-of>useAndReproduction</xsl:value-of>
                    </xsl:attribute>
                    <xsl:value-of>For more information about the use of this material, please go to
                        http://search.lib.virginia.edu/terms</xsl:value-of>
                </xsl:element>

                <xsl:element name="accessCondition">
                    <xsl:attribute name="type">
                        <xsl:value-of>restrictionOnAccess</xsl:value-of>
                    </xsl:attribute>
                </xsl:element>

                <!-- creates <recordInfo> -->

                <xsl:element name="recordInfo">
                    <xsl:element name="recordContentSource">
                        <xsl:attribute name="authority">
                            <xsl:value-of>marcorg</xsl:value-of>
                        </xsl:attribute>
                        <xsl:value-of>viu</xsl:value-of>
                    </xsl:element>
                    <xsl:element name="recordOrigin">
                        <xsl:value-of
                            select="concat(gdms/gdmshead/filedesc/pubstmt/note,'The records were then transformed from GDMS into MODS by Digital Curation Services, using JacksonDavis.xsl')"
                        />
                    </xsl:element>
                    <xsl:element name="languageOfCataloging">
                        <xsl:element name="languageTerm">
                            <xsl:attribute name="type">
                                <xsl:value-of>code</xsl:value-of>
                            </xsl:attribute>
                            <xsl:attribute name="authority">
                                <xsl:value-of>iso639-2b</xsl:value-of>
                            </xsl:attribute>
                            <xsl:value-of>eng</xsl:value-of>
                        </xsl:element>
                    </xsl:element>
                    <xsl:element name="recordCreationDate">
                        <xsl:attribute name="encoding">
                            <xsl:value-of>w3cdtf</xsl:value-of>
                        </xsl:attribute>
                        <xsl:value-of select="date:new()"/>
                    </xsl:element>
                </xsl:element>


            </mods>
        </xsl:result-document>
    </xsl:template>




</xsl:stylesheet>
