<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:my="local functions">

  <xsl:template match="cit">
    <xsl:text>\edtext{</xsl:text>
    <xsl:apply-templates select="ref|quote"/>
    <xsl:text>}</xsl:text>
    <xsl:text>{\lemma{</xsl:text>
    <xsl:if test="my:istrue($app-fontium-quote)">
      <xsl:choose>
        <xsl:when test="count(tokenize(normalize-space(quote), ' ')) &gt; 4">
          <xsl:value-of select="tokenize(normalize-space(quote), ' ')[1]"/>
          <xsl:text> \dots{} </xsl:text>
          <xsl:value-of select="tokenize(normalize-space(quote), ' ')[last()]"/>
          <xsl:text>}</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(quote)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:text>}</xsl:text>
    <xsl:choose>
      <xsl:when test="my:istrue($app-fontium-quote)">
        <xsl:text>\Afootnote{</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\Afootnote[nosep]{</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="bibl"/>
    <xsl:apply-templates select="note"/>
    <xsl:text>}}</xsl:text>
  </xsl:template>

  <xsl:template match="cit/bibl">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="note/bibl">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="ref">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="cit/note">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="quote">
    <xsl:choose>
      <xsl:when test="@type='paraphrase'">
        <xsl:apply-templates />
      </xsl:when>
      <xsl:when test="@type='lemma'">
        <xsl:text>\lemmaQuote{</xsl:text>
        <xsl:apply-templates />
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:when test="@type='direct' or not(@type)">
        <xsl:text> \enquote{</xsl:text>
        <xsl:apply-templates />
        <xsl:text>}</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="ref/name">
    <xsl:text>\name{</xsl:text>
    <xsl:call-template name="name"/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template name="name" match="name">
    <xsl:variable name="nameid" select="substring-after(./@ref, '#')"/>
    <xsl:apply-templates/>
    <xsl:text>\index[persons]{</xsl:text><xsl:value-of select="document($name-list-file)//tei:person[@xml:id=$nameid]/tei:persName[1]"/><xsl:text>} </xsl:text>
  </xsl:template>

  <xsl:template match="title">
    <xsl:text>\worktitle{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
    <xsl:choose>
      <xsl:when test="./@ref">
        <xsl:variable name="workid" select="substring-after(./@ref, '#')"/>
        <xsl:variable name="canonical-title" select="document($work-list-file)//tei:bibl[@xml:id=$workid]/tei:title[1]"/>
        <xsl:text>\index[works]{</xsl:text>
        <xsl:choose>
          <xsl:when test="$canonical-title">
            <xsl:value-of select="$canonical-title"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>No work with the id <xsl:value-of select="$workid"/> in workslist file (<xsl:value-of select="$work-list-file"/>)</xsl:message>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="no">No reference given for title/<xsl:value-of select="."/>.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
