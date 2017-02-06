<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:j="http://marklogic.com/json" xmlns:html="http://www.w3.org/1999/xhtml" xmlns="urn:isbn:1-931666-22-9"
	exclude-result-prefixes="j xs">
	<xsl:param name="country-code"/>
	<xsl:param name="identifier"/>
	
	<!-- collections which are in a particular collection  -->
	<xsl:key name="collections-by-parent-collection"
		match="/library/collections/j:item"
		use="string(j:data/j:parentCollection)"/>
	
	<!-- items in a particular collection (excluding items which are just part of other items) -->
	<xsl:key name="items-by-parent-collection"
		match="/library/items/j:item[not(j:data/j:parentItem)]"
		use="string(j:data/j:collections/j:item[1])"/>
		
	<!-- items which are part of another item -->
	<xsl:key name="items-by-parent-item"
		match="/library/items/j:item[j:data/j:parentItem]"
		use="string(j:data/j:parentItem)"/>
		
	<xsl:template match="/">
		<ead>
			<!-- The Zotero library doesn't have much header information, so the eadheader is necessarily sketchy -->
			<xsl:variable name="library" select="/library/collections/j:item[1]/j:library"/>
			<eadheader>
				<eadid identifier="{$identifier}"><xsl:if test="$country-code">
					<xsl:attribute name="countrycode">
						<xsl:value-of select="$country-code"/>
					</xsl:attribute>
				</xsl:if><xsl:value-of select="$identifier"/></eadid>
				<filedesc>
					<titlestmt>
						<!-- The title of the EAD finding aid is the name of the Zotero library -->
						<titleproper><xsl:value-of select="$library/j:name"/></titleproper>
						<!-- The finding aid authors are the users who created or modified the Zotero items -->
						<author>Zotero library authored by:<xsl:for-each-group select="//j:createdByUser | //j:lastModifiedbyUser" group-by="j:id">
							<xsl:for-each select="current-group()[1]"><lb/><xsl:value-of select="j:username"/><extptr xlink:type="simple" xlink:href="{j:links/j:alternate/j:href}"/></xsl:for-each>
						</xsl:for-each-group></author>
					</titlestmt>
				</filedesc>
				<profiledesc>
					<creation>Derived programmatically by <extref xlink:type="simple" xlink:href="mailto:conal.tuohy@gmail.com">Conal Tuohy</extref>, from the Zotero library <extref xlink:type="simple" xlink:href="{$library/j:links/j:alternate[1]/j:href}"><title><xsl:value-of select="$library/j:name"/></title></extref>, on <date normal="{format-date(current-date(), '[Y0001][M01][D01]')}"><xsl:value-of select="format-date(current-date(), '[MNn] [D], [Y]')"/></date>.</creation>
				</profiledesc>
			</eadheader>
			<!-- The Zotero library doesn't have much header information, so frontmatter is omitted -->
			<archdesc level="collection">
				<!-- The Zotero library doesn't have much header information, so archdesc/did is minimal -->
				<did><unittitle><xsl:value-of select="$library/j:name"/></unittitle></did>
				<dsc>
					<!-- list top-level collections -->
					<xsl:apply-templates select="key('collections-by-parent-collection', 'false')">
						<xsl:sort select="j:data/j:name"/>
					</xsl:apply-templates>
					<!-- list top-level items -->
					<xsl:comment> top-level items: <xsl:value-of select="count(key('items-by-parent-collection', ''))"/></xsl:comment>
					<xsl:apply-templates select="key('items-by-parent-collection', '')">
						<xsl:sort select="j:data/j:name"/>
					</xsl:apply-templates>
				</dsc>
			</archdesc>
		</ead>
	</xsl:template>
	
	<xsl:template match="j:language[.='eng' or .='en' or .='en-AU' or .='en_US' or .='English']">
		<language langcode="eng">English</language>
	</xsl:template>
	<xsl:template match="j:language[.='DINKA']">
		<language langcode="din">Dinka</language>
	</xsl:template>
	<xsl:template match="j:language[.='RUSSIAN']">
		<language langcode="rus">Russian</language>
	</xsl:template>
	
	<xsl:template match="/library/collections/j:item">
		<c id="collection-{j:data/j:key}">
			<did>
				<unittitle><xsl:value-of select="j:data/j:name"/></unittitle>
			</did>
			<!-- list items within this collection -->
			<xsl:apply-templates select="key('items-by-parent-collection', j:data/j:key)">
				<xsl:sort select="j:data/j:name"/>
			</xsl:apply-templates>
			
			<!-- list subordinate collections of this collection -->
			<xsl:apply-templates select="key('collections-by-parent-collection', j:data/j:key)">
				<xsl:sort select="j:data/j:name"/>
			</xsl:apply-templates>
		</c>
	</xsl:template>
	
	<xsl:template match="/library/items/j:item">
		<c id="item-{j:data/j:key}">
			<xsl:if test="j:data/j:collections/j:item">
				<xsl:attribute name="level">item</xsl:attribute>
			</xsl:if>
			<did>
				<unittitle><xsl:value-of select="
					normalize-space(
						concat(
							string-join(
								(j:data/j:title, j:data/j:filename[not(normalize-space()=normalize-space(../j:title))]),
								' — '
							),
							' (', 
							lower-case(
								replace(j:data/j:itemType, '([A-Z])', ' $1')
							),
							')'
						)
					)
				"/>
				<!-- j:date often (always?) has the ending " ... in [some place]" -->
				<xsl:for-each select="j:data/j:date">
					<xsl:text>, </xsl:text>
					<xsl:choose>
						<xsl:when test="contains(., ' in ')">
							<xsl:element name="unitdate">
								<xsl:value-of select="substring-before(., ' in ')"/>
							</xsl:element>
							<xsl:value-of select="concat(' in ', substring-after(., ' in '))"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="unitdate">
								<xsl:value-of select="."/>
							</xsl:element>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each></unittitle>
				<xsl:for-each select="j:data/j:callNumber"><unitid label="Call Number"><xsl:value-of select="."/></unitid></xsl:for-each>
				<xsl:for-each select="j:data/j:language">
					<xsl:element name="langmaterial">
						<xsl:apply-templates select="."/>
					</xsl:element>
				</xsl:for-each>
				<xsl:for-each select="j:data/j:abstractNote"><abstract><xsl:value-of select="."/></abstract></xsl:for-each>
			</did>
			<xsl:for-each select="j:data/j:rights">
				<userestrict><p><xsl:value-of select="."/></p></userestrict>
			</xsl:for-each>
			<xsl:if test="j:data/j:tags/j:item">
				<scopecontent>
					<list>
						<xsl:for-each select="j:data/j:tags/j:item/j:tag">
							<item><xsl:value-of select="."/></item>
						</xsl:for-each>
					</list>
				</scopecontent>
			</xsl:if>		
			<!-- TODO remaining descendants of j:item -->
			<!-- j:data children -->
			<!-- ignoring j:libraryCatalog -->
			<xsl:for-each select="j:data">
				<xsl:if test="
					j:title  | j:websiteTitle  | j:bookTitle  | j:shortTitle  | j:publicationTitle  | 
					j:edition | j:series | j:seriesNumber | j:issue | j:publisher  | j:place | j:volume |
					j:creators | j:university | j:archive | 
					j:numPages |  j:pages |
					j:DOI | j:ISSN | j:ISBN
				">
					<note>
						<p>
							<bibref>
								<!-- TODO format bibref properly -->
								<xsl:for-each select="j:title">
									<title><xsl:value-of select="."/></title>
								</xsl:for-each>
								<xsl:for-each select="j:websiteTitle">
									<title type="website"><xsl:value-of select="."/></title>
								</xsl:for-each>
								<!-- ignoring websiteType (="Text" always) -->
								<xsl:for-each select="j:bookTitle">
									<title type="book"><xsl:value-of select="."/></title>
								</xsl:for-each>
								<xsl:for-each select="j:shortTitle">
									<title type="short"><xsl:value-of select="."/></title>
								</xsl:for-each>
								<xsl:for-each select="j:edition">
									<edition><xsl:value-of select="."/></edition>
								</xsl:for-each>
								<xsl:for-each select="j:publicationTitle">
									<title type="publication"><xsl:value-of select="."/></title>
								</xsl:for-each>
								<xsl:for-each select="j:journalAbbreviation[not(.=../j:publicationTitle)]">
									<title type="journalAbbreviation"><xsl:value-of select="."/></title>
								</xsl:for-each>
								<xsl:for-each select="j:series">
									<bibseries><xsl:value-of select="."/><xsl:for-each select="j:seriesNumber"><num type="series"><xsl:value-of select="."/></num></xsl:for-each></bibseries>
								</xsl:for-each>
								<xsl:for-each select="j:issue">
									<num type="issue"><xsl:value-of select="."/></num>. 
								</xsl:for-each>
								<xsl:if test="j:publisher | j:place">
									<imprint>
										<xsl:for-each select="j:publisher">
											<publisher><xsl:value-of select="."/></publisher>
										</xsl:for-each>
										<xsl:for-each select="j:place">
											<geogname><xsl:value-of select="."/></geogname>
										</xsl:for-each>
									</imprint>
								</xsl:if>
								<xsl:for-each select="j:creators/j:item">
									<xsl:element name="persname">
										<xsl:attribute name="role"><xsl:value-of select="(j:creatorType, 'author')[1]"/></xsl:attribute>
										<xsl:value-of select="string-join(
											(j:firstName, j:lastName, j:name), ' '
										)"/>
									</xsl:element>
								</xsl:for-each>
								<xsl:for-each select="j:university">
									<corpname><xsl:value-of select="."/></corpname>
								</xsl:for-each>
								<xsl:for-each select="j:archive">
									<name><xsl:value-of select="."/></name>
								</xsl:for-each>
								<xsl:for-each select="j:numPages">
									<xsl:element name="num">
										<xsl:value-of select="."/>
										<xsl:choose>
											<xsl:when test="j:numPages='1'">p. </xsl:when>
											<xsl:otherwise>pp. </xsl:otherwise>
										</xsl:choose>
									</xsl:element>
								</xsl:for-each>
								<xsl:for-each select="j:DOI">
									<extref xlink:type="simple" xlink:href="http://dx.doi.org/{.}">doi:<xsl:value-of select="."/></extref>
								</xsl:for-each>
								<xsl:for-each select="j:ISSN"><num>ISSN:<xsl:value-of select="."/></num></xsl:for-each>
								<xsl:for-each select="j:ISBN"><num>ISBN:<xsl:value-of select="."/></num></xsl:for-each>
								<xsl:for-each select="j:volume"><num>vol <xsl:value-of select="."/></num></xsl:for-each>
								<xsl:for-each select="j:pages"><num>pages <xsl:value-of select="."/></num></xsl:for-each>
							</bibref>
						</p>
					</note>
				</xsl:if>
			</xsl:for-each>
			<!-- items with a j:url were imported from that location on the web -->
			<!-- here we represent this with an EAD note -->
			<xsl:if test="j:data/j:url">
				<xsl:element name="note">
					<xsl:element name="p">
						<xsl:text>Resource </xsl:text>
						<xsl:if test="j:data/j:contentType">
							<xsl:text>of type "</xsl:text>
							<xsl:value-of select="j:data/j:contentType"/>
							<xsl:text>"</xsl:text>
							<xsl:if test="j:data/j:charset">
								<xsl:text>, with character set "</xsl:text>
								<xsl:value-of select="j:data/j:charset"/>
								<xsl:text>",</xsl:text>
							</xsl:if>
						</xsl:if>
						<xsl:text> retrieved from </xsl:text>
						<xsl:element name="extptr">
							<xsl:attribute name="xlink:type">simple</xsl:attribute>
							<xsl:attribute name="xlink:href"><xsl:value-of select="j:data/j:url"/></xsl:attribute>
						</xsl:element>
						<xsl:if test="j:data/j:accessDate[normalize-space()]">	
							<xsl:text> on </xsl:text>
							<xsl:element name="date">
								<xsl:variable name="access-date" select="xs:date(substring(j:data/j:accessDate, 1, 10))"/>	
								<xsl:attribute name="normal">
									<xsl:value-of select="format-date($access-date, '[Y0001][M01][D01]')"/>
								</xsl:attribute>
								<xsl:value-of select="format-date($access-date, '[MNn] [D], [Y]')"/>
							</xsl:element>
						</xsl:if>
						<xsl:text>.</xsl:text>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!--
				53 with charset content
				accessDate (of original imported resource; always accompanies j:url)
				154 with accessDate content
				435 with url
				= 281 url without accessDate
				-->
			<xsl:for-each select="j:data/j:extra">
				<note type="zotero-extra"><p><xsl:value-of select="."/></p></note>
			</xsl:for-each>
			<!-- note is either a piece of content or else an ead:note with embedded markup which should be sanitised -->
			<xsl:if test="j:data/j:note[normalize-space()]">

				<xsl:choose>
					<xsl:when test="(string-length(j:data/j:note) &gt; 2000)">
						<!-- treat the note as a digital object -->
						<xsl:variable name="note-url" select="
							concat('data:text/html;charset=utf-8,', encode-for-uri(j:data/j:note))
						"/>
						<dao xlink:title="Note" xlink:type="simple" xlink:href="{$note-url}" entityref="{j:data/j:key}">
							<daodesc>
								<p>(text/html)</p>
							</daodesc>
						</dao>
						<!--
						<xsl:variable name="note" select="j:links/j:alternate[j:type='text/html']"/>
						<dao xlink:title="Note" xlink:type="simple" xlink:href="{$note/j:href}">
							<daodesc>
								<p>(<xsl:value-of select="$note/j:type"/>)</p>
							</daodesc>
						</dao>
						-->
					</xsl:when>
					<xsl:otherwise>
						<!-- treat the note as metadata -->
						<xsl:variable name="normalized-note" select="
							normalize-space(
								replace(
									j:data/j:note,
									'&lt;[^&gt;]*&gt;',
									' '
								)
							)
						"/>
						<note type="zotero-note"><p><xsl:value-of select="$normalized-note"/></p></note>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<!--
				contentType (2251) (2152 without j:url, 17 without j:enclosure, 0 with neither j:url or j:enclosure.
				md5 (2234) (all have enclosure), filename (2236)
			-->
			<!-- j:links/j:enclosure (n=2234) children -->
			<!-- title (n=2199) (filename), length (n=2199) (bytes), type (n=2234) (=content-type), href (n=2234) (download URL) all dao, daodesc, etc.-->
			<xsl:for-each select="j:links/j:enclosure">
				<dao xlink:title="{(j:title, ../../j:data/j:filename)[1]}" xlink:type="simple" xlink:href="{j:href}">
					<daodesc>
						<p>(<xsl:value-of select="j:type"/>), <xsl:if test="j:length"><xsl:value-of select="j:length"/> bytes, </xsl:if>md5 hash=<xsl:value-of select="../../j:data/j:md5"/>.</p>
					</daodesc>
				</dao>
			</xsl:for-each>
			
			<!-- list subordinate items of this item -->
			<xsl:apply-templates select="key('items-by-parent-item', j:data/j:key)">
				<xsl:sort select="j:data/j:title"/>
				<xsl:sort select="j:data/j:note"/>
			</xsl:apply-templates>
		</c>
	</xsl:template>
	
	<xsl:template match="html:p" mode="html-to-ead">
		<p><xsl:apply-templates mode="html-to-ead"/></p>
	</xsl:template>
	
</xsl:stylesheet>
					
