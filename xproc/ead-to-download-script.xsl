<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:j="http://marklogic.com/json" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:lookup="tag:conaltuohy.com,2017:lookup"
	exclude-result-prefixes="j xs lookup">

	<xsl:import href="dao-local-filename.xsl"/>
	<xsl:param name="key"/>
	<xsl:output method="text"/>
	
		
	<xsl:template match="/">
		<script>
			<command>
				<xsl:text>mkdir dao</xsl:text>
				<xsl:value-of select="codepoints-to-string(10)"/>
			</command>
			<!-- generate a command to download each dao whose URI contains a colon (i.e. not a local file) -->
			<xsl:for-each select="//ead:dao[contains(@xlink:href, ':')]">
				<command>
					<xsl:text>wget </xsl:text>
					<xsl:text>--header="Authorization: Bearer </xsl:text>
					<xsl:value-of select="$key"/>
					<xsl:text>" </xsl:text>
					<xsl:text>--output-document=</xsl:text>
					<xsl:apply-templates select="." mode="make-dao-local-filename"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="@xlink:href"/>
					<xsl:value-of select="codepoints-to-string(10)"/>
				</command>
			</xsl:for-each>
		</script>
	</xsl:template>
	
</xsl:stylesheet>
					
