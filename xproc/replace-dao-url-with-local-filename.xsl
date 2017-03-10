<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:j="http://marklogic.com/json" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:lookup="tag:conaltuohy.com,2017:lookup"
	exclude-result-prefixes="j xs lookup">

	<xsl:import href="dao-local-filename.xsl"/>
	
	<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="ead:dao[contains(@xlink:href, ':')]">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="xlink:href">
				<xsl:apply-templates select="." mode="make-dao-local-filename"/>
			</xsl:attribute>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
					
