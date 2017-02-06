<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:html="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="html">
	
	<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:head">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
			<title>Note</title>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
					
