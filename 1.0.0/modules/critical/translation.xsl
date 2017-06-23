<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:my="local functions">

  <xsl:template name="documentDiv">
    <xsl:param name="content"/>
    <xsl:param name="inParallelText"/>
    <xsl:apply-templates select="$content">
      <xsl:with-param name="inParallelText" select="$inParallelText"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:variable name="translationFile">
    <xsl:variable name="absolute-path" select="base-uri(.)"/>
    <xsl:variable name="base-filename" select="tokenize($absolute-path, '/')[last()]"/>
    <xsl:variable name="parent" select="string-join(tokenize($absolute-path,'/')[position() &lt; last()], '/')" />
    <xsl:variable name="translation-file" select="concat($parent, '/translation-', $base-filename)"/>
    <xsl:choose>
      <xsl:when test="$translation-file">
        <xsl:value-of select="$translation-file"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          The translation file $translation-file cannot be found!
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

</xsl:stylesheet>
