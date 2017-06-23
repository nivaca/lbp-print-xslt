<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:my="local functions">

  <!-- Wrap supplied, secluded, notes, and unclear in appropriate tex macros -->
  <xsl:template match="supplied">
    <xsl:choose>
      <xsl:when test="@ana='#meta-text'">
        <xsl:text>\metatext{</xsl:text>
      </xsl:when>
      <xsl:when test="@ana='#in-vacuo'">
        <xsl:text>\suppliedInVacuo{</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\supplied{</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="surplus">\secluded{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="unclear">\emph{<xsl:apply-templates/> [?]}</xsl:template>
  <xsl:template match="desc">\emph{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="abbr">\emph{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="app//mentioned">\emph{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="mentioned">`<xsl:apply-templates/>'</xsl:template>
  <xsl:template match="sic[@ana='#crux']">\corruption{<xsl:apply-templates/>}</xsl:template>

  <xsl:template match="pb | cb" name="createPageColumnBreak">
    <xsl:param name="context" select="."/>
    <xsl:param name="withIndicator" select="true()"/>
    <xsl:param name="inParallelText" />
    <xsl:if test="not($inParallelText)">
      <xsl:for-each select="$context">
        <xsl:choose>
          <xsl:when test="self::pb">
            <xsl:if test="$withIndicator">
              <xsl:text>\textnormal{|}</xsl:text>
            </xsl:if>
            <xsl:text>\ledsidenote{</xsl:text>
            <xsl:value-of select="translate(./@ed, '#', '')"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="translate(./@n, '-', '')"/>
            <xsl:if test="following-sibling::*[1][self::cb]">
              <xsl:value-of select="following-sibling::cb[1]/@n"/>
            </xsl:if>
            <xsl:text>}</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="not(preceding-sibling::*[1][self::pb])">
              <xsl:if test="$withIndicator">
                <xsl:text>\textnormal{|}</xsl:text>
              </xsl:if>
              <xsl:text>\ledsidenote{</xsl:text>
              <xsl:value-of select="translate(./@ed, '#', '')"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="translate(preceding::pb[./@ed = $context/@ed][1]/@n, '-', '')"/>
              <xsl:value-of select="./@n"/>
              <xsl:text>}</xsl:text>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template match="seg">
    <xsl:if test="@type='target'">
      <xsl:call-template name="createLabelFromId">
        <xsl:with-param name="labelType">start</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="@type='target'">
      <xsl:call-template name="createLabelFromId">
        <xsl:with-param name="labelType">end</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
