<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xpath-default-namespace="http://www.loc.gov/mods/v3" xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="mods fn xs">
	<xsl:param name="verbose">
		<xsl:value-of select="false()"/>
	</xsl:param>
	<xsl:param name="pid">
		<xsl:value-of select="//identifier[@displayLabel='UVA Library Fedora Repository PID'][1]"/>
	</xsl:param>
	<xsl:param name="setcode" select="/mods:mods/mods:relatedItem[1]/mods:titleInfo[1]/title"></xsl:param>
	<xsl:param name="repository">http://fedoratest.lib.virginia.edu:8080/fedora</xsl:param>
		<xsl:param name="dateIngestNow"><xsl:value-of select="false()"/></xsl:param>
	<xsl:param name="addDayofWeek" select="false()"/>
	<xsl:param name="shadowedItem"><xsl:value-of select="false()"/></xsl:param>
	<xsl:param name="contentModel">jp2k</xsl:param>
	<xsl:param name="collectionName" select="//relatedItem[@type='series']/titleInfo[1]/title[1]"></xsl:param>
	<xsl:output byte-order-mark="no" encoding="UTF-8" media-type="text/xml" xml:space="preserve" indent="yes"></xsl:output>
	<!-- UVA-LIB stylesheet for MODS to SOLR 			-->
	<!-- created by M. Stephens (ms3uf) on Jan 14/2010 	-->
	<xsl:template match="/">
		<xsl:if test="$verbose=true()">
			<xsl:message>Processing mods record <xsl:value-of select="$pid"/> ...</xsl:message>
		</xsl:if>
		<xsl:variable name="dayOfWeek">
			<!-- custom requirement for Holsinger collection (legacy) -->
			<xsl:for-each select="//dateCreated[@qualifier='inferred']">
				<xsl:if test="current()/text()">
					<xsl:value-of select="."/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<add>
			<doc>
				<field name="id"><xsl:value-of select="$pid"/></field>
				<field name="digital_collection_facet"><xsl:value-of select="$collectionName"/></field>
				<field name="setcode_facet"><xsl:value-of select="$setcode"/></field>
				<field name="content_model_facet"><xsl:value-of select="$contentModel"/></field>
				<field name="repository_address_display"><xsl:value-of select="$repository"/></field>
				<field name="source_facet">UVA Library Digital Repository</field>

				<!-- title -->
				<xsl:for-each select="//mods:title">
					<xsl:if test="position() = 1 or @type='uniform'">
						<field name="main_title_display"><xsl:value-of select="current()"/></field>
						<!-- there can be only one! title facet will BREAK solr sorting if multiple values found -->
						<field name="title_facet"><xsl:value-of select="current()"/></field>
						<field name="title_text"><xsl:value-of select="current()"/></field>
						<field name="title_display"><xsl:value-of select="current()"/></field>
					</xsl:if>
				</xsl:for-each>
				<xsl:if test="not(//mods/*[1][local-name() = 'titleInfo']/*[local-name() = 'title'])">
					<field name="alternate_title_display">untitled</field>
				</xsl:if>

				<!-- call number (or equivalent search text) -->
				<xsl:for-each select="//identifier[(@displayLabel='Call Number') or (@displayLabel='Negative Number')]">
					<field name="media_retrieval_id_display"><xsl:value-of select="current()"/></field>
					<field name="media_retrieval_id_facet"><xsl:value-of select="current()"/></field>
				</xsl:for-each>

				<!-- SOLR can take only one year_multisort_i field, so we need to choose which mods element to utilize -->
				<xsl:for-each select="//originInfo[1]">
				<xsl:choose>
					<xsl:when test="current()/dateIssued[@keyDate='yes'][1]">
						<xsl:call-template name="build-dates">
						<xsl:with-param name="date-node" select="current()/dateIssued[@keyDate='yes'][1]"/>
						<xsl:with-param name="day-of-week" select="$dayOfWeek"/>
						</xsl:call-template>
						<xsl:if test="$verbose=true()"><xsl:message>found dateIssued keydate: <xsl:value-of select="current()/dateIssued[@keyDate='yes'][1]"/></xsl:message></xsl:if>
					</xsl:when>
					<xsl:when test="current()/dateCreated[@keyDate='yes'][1]">
						<xsl:call-template name="build-dates">
						<xsl:with-param name="date-node" select="current()/dateCreated[@keyDate='yes'][1]"/>
						<xsl:with-param name="day-of-week" select="$dayOfWeek"/>
						</xsl:call-template>
						<xsl:if test="$verbose=true()"><xsl:message>found dateCreated keydate: <xsl:value-of select="current()/dateCreated[@keyDate='yes'][1]"/></xsl:message></xsl:if>
					</xsl:when>
					<xsl:when test="current()/dateCaptured[@keyDate='yes'][1]">
						<xsl:call-template name="build-dates">
						<xsl:with-param name="date-node" select="current()/dateCaptured[@keyDate='yes'][1]"/>
						<xsl:with-param name="day-of-week" select="$dayOfWeek"/>
						</xsl:call-template>
						<xsl:if test="$verbose=true()"><xsl:message>found dateCaptured keydate: <xsl:value-of select="current()/dateCaptured[@keyDate='yes'][1]"/></xsl:message></xsl:if>
					</xsl:when>
					<xsl:when test="current()/dateValid[@keyDate='yes'][1]">
						<xsl:call-template name="build-dates">
						<xsl:with-param name="date-node" select="current()/dateValid[@keyDate='yes'][1]"/>
						<xsl:with-param name="day-of-week" select="$dayOfWeek"/>
						</xsl:call-template>
						<xsl:if test="$verbose=true()"><xsl:message>found dateValid keydate: <xsl:value-of select="current()/dateValid[@keyDate='yes'][1]"/></xsl:message></xsl:if>
					</xsl:when>
					<xsl:when test="current()/copyrightDate[@keyDate='yes'][1]">
						<xsl:call-template name="build-dates">
						<xsl:with-param name="date-node" select="current()/copyrightDate[@keyDate='yes'][1]"/>
						<xsl:with-param name="day-of-week" select="$dayOfWeek"/>
						</xsl:call-template>
						<xsl:if test="$verbose=true()"><xsl:message>found copyrightDate keydate: <xsl:value-of select="current()/copyrightDate[@keyDate='yes'][1]"/></xsl:message></xsl:if>
					</xsl:when>
					<xsl:when test="current()/dateOther[@keyDate='yes'][1]">
						<xsl:call-template name="build-dates">
						<xsl:with-param name="date-node" select="current()/dateOther[@keyDate='yes'][1]"/>
						<xsl:with-param name="day-of-week" select="$dayOfWeek"/>
						</xsl:call-template>
						<xsl:if test="$verbose=true()"><xsl:message>found dateOther keydate: <xsl:value-of select="current()/dateOther[@keyDate='yes'][1]"/></xsl:message></xsl:if>
					</xsl:when>
					<xsl:otherwise/>
				</xsl:choose>
				</xsl:for-each>

				<!-- day of the week (custom for Holsinger) -->
				<xsl:if test="$collectionName = 'Holsinger Studio Collection' and $addDayofWeek = true()">
				<xsl:for-each select="//dateCreated[@qualifier='inferred']">
					<xsl:if test="current()/text()">
						<field name="dayOfWeek_display"><xsl:value-of select="."/></field>
						<field name="dayOfWeek_text"><xsl:value-of select="."/></field>
						<field name="dayOfWeek_facet"><xsl:value-of select="."/></field>
					</xsl:if>
				</xsl:for-each>

				</xsl:if>
				
				<!-- subject text -->
				<xsl:for-each select="//subject">
					<xsl:variable name="text-content">
					<xsl:for-each select="./descendant::text()[matches(., '[\w]+')]">
						<xsl:if test="matches(current(), '[\w]+')">
							<!-- add double dash to all trailing subfields -->
							<xsl:if test="position() != 1">
							<xsl:text> -- </xsl:text>
							</xsl:if>
							<xsl:copy-of select="normalize-space(current())"/>
						</xsl:if>

					</xsl:for-each>
				</xsl:variable>
				
					<xsl:choose>
						<xsl:when test="matches($text-content, '[\w]+')">
							<field name="subject_text"><xsl:value-of select="$text-content"/></field>
							<field name="subject_facet"><xsl:value-of select="$text-content"/></field>
							<field name="subject_genre_facet"><xsl:value-of select="$text-content"/></field>
						</xsl:when>
						<xsl:otherwise/>
					</xsl:choose>
				</xsl:for-each>

				<!-- place -->
				<xsl:for-each select="//place/placeTerm[not(@authority='marccountry')]">
					<xsl:choose>
						<xsl:when test="current()/text()= ''"/>
						<xsl:otherwise>
							<field name="geographic_location_facet"><xsl:value-of select="current()"/></field>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>

				<!-- library facet -->
				<xsl:for-each select="//location/physicalLocation[not(@authority='oclcorg')]">
					<xsl:variable name="shortLocation" xml:space="default">
						<xsl:analyze-string select="current()/text()[1]" regex="^[\w\s]+">
							<xsl:matching-substring><xsl:value-of select="."/></xsl:matching-substring>
						</xsl:analyze-string>
					</xsl:variable>
					<xsl:if test="current()/text() != ' '">
						<field name="library_facet"><xsl:value-of select="$shortLocation"/></field>
						<field name="location_display"><xsl:value-of select="current()/text()"/></field>
					</xsl:if>
				</xsl:for-each>

				<!-- creator -->
				<xsl:for-each select="//mods/name[@type='personal']">
					<xsl:variable name="fname">
						<xsl:choose>
							<xsl:when test="current()/namePart[@type='family'] and current()/namePart[@type='family'][substring-before(., ',')!='']">
								<xsl:value-of select="substring-before(current()/namePart[@type='family'], ',')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="current()/namePart[@type='family']"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="gname">
						<xsl:choose>
							<xsl:when test="current()/namePart[@type='given'] and current()/namePart[@type='given'][substring-before(., ',')!='']">
								<xsl:value-of select="substring-before(current()/namePart[@type='given'], ',')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="current()/namePart[@type='given']"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="term-of-address">
						<xsl:choose>
							<xsl:when test="current()/namePart[@type='termsOfAddress'] and current()/namePart[@type='termsOfAddress'][substring-before(., ',')!='']">
								<xsl:value-of select="substring-before(current()/namePart[@type='termsOfAddress'], ',')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="current()/namePart[@type='termsOfAddress']"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="nameFull">
						<xsl:choose>
							<xsl:when test="current()/namePart[@type='family'] and current()/namePart[@type='given']">
								<xsl:value-of select="$fname"/><xsl:text>, </xsl:text><xsl:value-of select="$gname"/>
							</xsl:when>
							<xsl:when test="current()/namePart[@type='family'] and current()/namePart[@type='termsOfAddress']">
								<xsl:value-of select="$fname"/><xsl:text>, </xsl:text><xsl:value-of select="$term-of-address"/>
							</xsl:when>
							<xsl:when test="current()/namePart[@type='given'] and current()/namePart[@type='termsOfAddress']">
								<xsl:value-of select="$gname"/><xsl:text>, </xsl:text><xsl:value-of select="$term-of-address"/>
							</xsl:when>
							<xsl:when test="contains(current()/namePart[not(@type = 'date')][not(@type = 'termsOfAddress')][1], ',') and count(current()/namePart) = 1">
								<xsl:value-of select="current()/namePart[1]"/>
							</xsl:when>
							<xsl:when test="current()/namePart[not(@type = 'date')]">
								<xsl:for-each select="current()/namePart[not(@type = 'date')]">
								<xsl:choose>
									<xsl:when test="contains(., ',') and substring-after(., ',')=''"><xsl:value-of select="substring-before(., ',')"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
								</xsl:choose>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="current()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<field name="author_facet"><xsl:value-of select="$nameFull"/></field>
					<xsl:variable name="special-role">
						<xsl:if test="current()/role/roleTerm[not(@type='code')][not(contains(., 'creator'))]"> (<xsl:value-of select="current()/role/roleTerm[not(@type='code')][not(contains(., 'creator'))]"/>)</xsl:if>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="child::namePart[@type='date']">
							<field name="author_display"><xsl:value-of select="$nameFull"/>, <xsl:value-of select="child::namePart[@type='date']/text()"/><xsl:value-of select="$special-role"/></field>
						</xsl:when>
						<xsl:otherwise>
							<field name="author_display"><xsl:value-of select="$nameFull"/><xsl:value-of select="$special-role"/></field>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>

				<!-- series facet -->
				<xsl:for-each select="//mods/relatedItem[@type='series']">
					<xsl:variable name="dateRange" xml:space="default">
						<xsl:choose>
							<xsl:when test="//mods/relatedItem[1]/originInfo[1]/dateCreated[@point='start'] and
								//mods/relatedItem[1]/originInfo[1]/dateCreated[@point='end']">, <xsl:value-of select="//mods/relatedItem[1]/originInfo[1]/dateCreated[@point='start']"/> - <xsl:value-of
									select="//mods/relatedItem[1]/originInfo[1]/dateCreated[@point='end']"/></xsl:when>
							<xsl:when test="//mods/relatedItem[1]/originInfo[1]/dateCreated[@point='start']">, <xsl:value-of
									select="//mods/relatedItem[1]/originInfo[1]/dateCreated[@point='start']"/> - ?</xsl:when>
							<xsl:when test="//mods/relatedItem[1]/originInfo[1]/dateCreated[@point='end']">, ? - <xsl:value-of
									select="//mods/relatedItem[1]/originInfo[1]/dateCreated[@point='end']"/>)</xsl:when>
							<xsl:otherwise/>
						</xsl:choose>
					</xsl:variable>
					<field name="series_title_text">
						<xsl:value-of select="current()/@displayLabel"/>
						<xsl:for-each select="current()/titleInfo/descendant::*">
							<xsl:text> </xsl:text>
							<xsl:value-of select="."/>
						</xsl:for-each>
					</field>
					<field name="series_title_facet">
						<xsl:for-each select="current()/titleInfo/descendant::*[local-name() != 'nonSort']">
							<xsl:value-of select="."/>
							<xsl:if test="position() != last()">
								<xsl:text> </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</field>
					<field name="series_title_display">
						<xsl:for-each select="current()/titleInfo/descendant::*[local-name() != 'nonSort']">
							<xsl:value-of select="."/>
							<xsl:value-of xml:space="default" select="$dateRange"/>
							<xsl:if test="position() != last()">
								<xsl:text> </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</field>
				</xsl:for-each>

				<!-- date (range) -->
				<xsl:for-each select="/mods/relatedItem[1]/originInfo[1]">
					<field name="startDate_text"><xsl:value-of select="current()/dateCreated[@point='start']"/></field>
					<field name="endDate_text"><xsl:value-of select="current()/dateCreated[@point='end']"/></field>
				</xsl:for-each>

				<!-- format facet -->
				<xsl:for-each select="//mods/genre">
					<field name="format_text"><xsl:value-of select="current()"/></field>
					<field name="format_facet"><xsl:value-of select="current()"/></field>
				</xsl:for-each>

				<!-- genre -->
				<xsl:for-each select="//mods/genre">
					<field name="genre_text"><xsl:value-of select="current()"/></field>
					<field name="genre_facet"><xsl:value-of select="current()"/></field>
				</xsl:for-each>

				<!-- physical description -->
				<xsl:for-each select="//mods/physicalDescription">
					<xsl:variable name="descriptionDisplay">
						<xsl:for-each select="current()/child::*">
							<xsl:choose>
								<xsl:when test="local-name() = 'form'"><xsl:value-of select="."/>; </xsl:when>
								<xsl:when test="local-name() = 'note' and ./@displayLabel = 'condition' and not( matches( text(),
									'^\s+$'))">
									<xsl:value-of select="."/>
								</xsl:when>
								<xsl:when test="local-name() = 'note' and ./@displayLabel = 'size inches'">
									<xsl:text xml:space="default">Plate size: </xsl:text>
									<xsl:value-of select="."/>
									<xsl:text xml:space="default"> inches; </xsl:text>
								</xsl:when>
								<xsl:otherwise/>
							</xsl:choose>
						</xsl:for-each>
					</xsl:variable>
					<xsl:if test="$descriptionDisplay">
						<field name="media_description_display"><xsl:value-of select="$descriptionDisplay"/></field>
						<field name="desc_meta_file_display"><xsl:value-of select="$descriptionDisplay"/></field>
					</xsl:if>
				</xsl:for-each>

				<!-- staff note -->
				<xsl:for-each select="//mods/note[@displayLabel='staff']">
					<xsl:if test="./text() != ' '">
						<field name="note_text">Staff note: <xsl:value-of select="current()"/></field>
						<!-- use if you want this data to be searchable -->
						<field name="note_display">Staff note: <xsl:value-of select="current()"/></field>
						<!-- use if you want this data to be available for display in blacklight brief or full record -->
					</xsl:if>
				</xsl:for-each>

				<!-- use and access (rough version) -->
				<xsl:for-each select="//accessCondition[@type='restrictionOnAccess']">
					<xsl:variable name="accessRestriction">
						<!-- If access restriction element is empty, we will restrict object by default -->
						<xsl:choose>
							<xsl:when test="current()/text()"><xsl:value-of select="normalize-space(current())"/></xsl:when>
							<xsl:otherwise>RESTRICTED</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<field name="access_display"><xsl:value-of select="current()/@displayLabel"/>: <xsl:value-of select="$accessRestriction"/></field>
					<field name="access_text"><xsl:value-of select="$accessRestriction"/></field>
				</xsl:for-each>
				<xsl:for-each select="//accessCondition[@type='useAndReproduction']">
					<xsl:variable name="accessUse">
						<!-- If use restriction element is empty, we will restrict object by default -->
						<xsl:choose>
							<xsl:when test="current()/text()"><xsl:value-of select="normalize-space(current())"/></xsl:when>
							<xsl:otherwise>RESTRICTED</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<field name="access_display"><xsl:value-of select="current()/@displayLabel"/>: <xsl:value-of select="$accessUse"/></field>
					<field name="access_text"><xsl:value-of select="$accessUse"/></field>
				</xsl:for-each>

				<!-- 		this (arbitary) dateTime gets added to every record 			-->
				<!-- default blacklight behavior is to sort by this date (newest first) 			-->
				<!-- default behavior here is to plug in Feb 2, 2010 unless $ingestDate set	-->
				<xsl:choose>
					<xsl:when test="$dateIngestNow = false() and //recordInfo/recordCreationDate[@encoding='marc']">
						<xsl:variable name="marcdate"><xsl:call-template name="format-marc-date">
						<xsl:with-param name="date" select="//recordInfo/recordCreationDate[@encoding='marc'][1]"/>
						</xsl:call-template>
						</xsl:variable>
						<field name="date_received_facet"><xsl:value-of select="$marcdate"/></field>
						<xsl:if test="$verbose">
							<xsl:message>FOUND MARC CREATION DATE<xsl:value-of select="fn:dateTime(xs:date($marcdate), xs:time('00:00:00'))"/></xsl:message>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$dateIngestNow = false() and $shadowedItem = false()">
						<field name="date_received_facet"><xsl:value-of select="fn:dateTime(xs:date('2010-02-01'), xs:time('12:00:00'))"/>Z</field>
					</xsl:when>
					<xsl:when test="$dateIngestNow = false() and $shadowedItem = true()">
						<!-- shadowed items get older timestamps so the don't come up first in Blacklight/Solr, whihc sorts on this field -->
						<field name="date_received_facet"><xsl:value-of select="fn:dateTime(xs:date('1999-12-31'), xs:time('23:59:59'))"/>Z</field>
					</xsl:when>
					<xsl:when test="$collectionName = 'Holsinger Studio Collection'">
						<field name="date_received_facet">2010-02-01T00:00:00Z</field>
					</xsl:when>
	                    		<xsl:otherwise>
						<field name="date_received_facet"><xsl:value-of select="fn:current-dateTime()"/></field>
					</xsl:otherwise>
				</xsl:choose>

				<!-- set "shadowed_location_facet" field -->
				<xsl:element name="field">
					<xsl:attribute name="name">shadowed_location_facet</xsl:attribute>
					<xsl:choose>
						<xsl:when test="$shadowedItem = true()">
							<xsl:text>HIDDEN</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>VISIBLE</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>

			</doc>
		</add>
	</xsl:template>

	<xsl:template name="format-marc-date">
		<xsl:param name="date"/>
		<xsl:variable name="prefix">
			<xsl:choose>
				<xsl:when test="fn:substring($date, 1, 1) = '0'"><xsl:text>20</xsl:text></xsl:when>
				<xsl:otherwise><xsl:text>19</xsl:text></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="output">
			<xsl:text>20</xsl:text><xsl:value-of select="fn:substring($date, 1, 2)"/>-<xsl:value-of select="fn:substring($date, 3, 2)"/>-<xsl:value-of select="fn:substring($date, 5, 2)"/>
		</xsl:variable>
		<xsl:if test="fn:string-length($date) = 6">
			<xsl:if test="$verbose">
				<xsl:message>date is ::<xsl:value-of select="$date"/>::</xsl:message>
				<xsl:message>output is ::<xsl:value-of select="$output"/>::</xsl:message>
			</xsl:if>
		<xsl:value-of select="$output"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="build-dates">
		<xsl:param name="date-node" select="'No node sent to template build-dates'"/>
		<xsl:param name="day-of-week"/>
		<xsl:for-each select="$date-node">
			<xsl:choose>
				<xsl:when test="matches(., '^\d{4}')">
					<xsl:variable name="yearOnly">
						<xsl:value-of select="substring(., 1, 4)"/>
					</xsl:variable>
					<field name="year_multisort_i"><xsl:value-of select="$yearOnly"/></field>
					<field name="year_display"><xsl:value-of select="."/>
					<xsl:if test="matches($day-of-week, '\w')"> (<xsl:value-of select="$day-of-week"/>)</xsl:if></field>
					<field name="date_text"><xsl:value-of select="."/></field>
				</xsl:when>
				<xsl:when test="./text() = 'Unknown Date' or ./text() = 'Unknown date'">
					<field name="published_date_display"><xsl:value-of select="."/></field>
				</xsl:when>
				<xsl:otherwise>
					<field name="published_date_display"><xsl:value-of select="."/><xsl:if test="matches($day-of-week, '\w')"> (<xsl:value-of select="$day-of-week"/>)</xsl:if></field>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
