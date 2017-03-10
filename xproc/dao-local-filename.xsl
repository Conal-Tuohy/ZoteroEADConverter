<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:j="http://marklogic.com/json" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:lookup="tag:conaltuohy.com,2017:lookup"
	exclude-result-prefixes="j xs lookup">
	
	
	<lookup:extensions>
		<extension type="application/pdf">.pdf</extension>
		<extension type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet">.xsls</extension>
		<extension type="application/vnd.openxmlformats-officedocument.wordprocessingml.document">.docx</extension>
		<extension type="application/msword">.doc</extension>
		<extension type="image/jpeg">.jpg</extension>
		<extension type="audio/mpeg">.mp3</extension>
		<extension type="text/rtf">.rtf</extension>
		<extension type="text/html">.html</extension>
	</lookup:extensions>
	
	<xsl:variable name="extensions" select="document('')/*/lookup:extensions/*"/>

	<xsl:template mode="make-dao-local-filename" match="ead:dao[contains(@xlink:href, ':')]">
		<!-- generate a file extension -->
		<xsl:variable name="content-type" select="
			replace(
				ead:daodesc/ead:p,
				'\(([^/]+/[^\)]+)\).*',
				'$1'
			)
		"/>
		<xsl:variable name="extension" select="$extensions[@type=$content-type]"/>
		<xsl:text>dao/</xsl:text>
		<xsl:value-of select="encode-for-uri(@xlink:href)"/>
		<xsl:value-of select="$extension"/>
	</xsl:template>
	
</xsl:stylesheet>
					
