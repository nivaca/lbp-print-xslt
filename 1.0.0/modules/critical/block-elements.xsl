<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:my="local functions">

  <xsl:template match="head">
    <xsl:if test="not(following-sibling::p)">
      \extrasubsection*{<xsl:apply-templates/>}
    </xsl:if>
  </xsl:template>

  <xsl:template name="paragraphs" match="p">
    <xsl:param name="inParallelText"/>
    <xsl:variable name="pn"><xsl:number level="any" from="tei:text"/></xsl:variable>
    <xsl:variable name="p_count" select="count(//body/div/descendant::p)"/>
    <xsl:variable name="p_position">
      <xsl:number from="/TEI/text/body/div" level="any"/>
    </xsl:variable>
    <xsl:if test="$pn='1'">
      <xsl:text>&#xa;&#xa;\begin{</xsl:text>
      <xsl:value-of select="$text_language"/>
      <xsl:text>}</xsl:text>
      <xsl:text>&#xa;\beginnumbering
      </xsl:text>
    </xsl:if>
    <xsl:text>&#xa;\pstart</xsl:text>
    <xsl:if test="preceding-sibling::*[1][self::head] or
                  ((parent::div[1]/translate(@ana, '#', '') = $structure-types/*) and (position() = 1))">
      <xsl:text>[</xsl:text>
      <xsl:if test="preceding-sibling::head">
        <xsl:text>\extrasubsection{</xsl:text>
        <xsl:apply-templates select="preceding-sibling::head/node()"/>
        <xsl:text>}</xsl:text>
      </xsl:if>
      <xsl:text>]</xsl:text>
    </xsl:if>
    <xsl:text>&#xa;</xsl:text>
    <xsl:call-template name="createLabelFromId">
      <xsl:with-param name="labelType">start</xsl:with-param>
    </xsl:call-template>
    <xsl:if test="$pn='1'">
      <xsl:text>&#xa;</xsl:text>
      <xsl:call-template name="createPageColumnBreak">
        <xsl:with-param name="withIndicator" select="false()"/>
        <xsl:with-param name="context" select="$starts_on"/>
        <xsl:with-param name="inParallelText" select="$inParallelText"/>
      </xsl:call-template>
      <xsl:text>%</xsl:text>
    </xsl:if>
    <xsl:call-template name="createStructureNumber"/>
    <xsl:apply-templates/>
    <xsl:text>%&#xa;</xsl:text>
    <xsl:call-template name="createLabelFromId">
      <xsl:with-param name="labelType">end</xsl:with-param>
    </xsl:call-template>
    <xsl:text>&#xa;\pend&#xa;</xsl:text>
    <xsl:if test="$p_position = $p_count">
      <xsl:text>&#xa;&#xa;\endnumbering</xsl:text>
      <xsl:text>&#xa;\end{</xsl:text>
      <xsl:value-of select="$text_language"/>
      <xsl:text>}</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="createLabelFromId">
    <xsl:param name="labelType" />
    <xsl:if test="@xml:id">
      <xsl:choose>
        <xsl:when test="$labelType='start'">
          <xsl:text>\edlabelS{</xsl:text>
          <xsl:value-of select="@xml:id"/>
          <xsl:text>}%</xsl:text>
        </xsl:when>
        <xsl:when test="$labelType='end'">
          <xsl:text>\edlabelE{</xsl:text>
          <xsl:value-of select="@xml:id"/>
          <xsl:text>}</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>\edlabel{</xsl:text>
          <xsl:value-of select="@xml:id"/>
          <xsl:text>}</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="div[translate(@ana, '#', '') = $structure-types/*
                       and not(@n)]">
    <xsl:if test="my:isfalse($parallel-translation)">
      <!-- The parallel typesetting does not work well with manually added space
           because of syncronization -->
      <xsl:text>&#xa;\medbreak&#xa;</xsl:text>
    </xsl:if>
    <xsl:apply-templates />
  </xsl:template>

  <xsl:param name="structure-types">
    <n>rationes-principales-pro</n>
    <n>rationes-principales-contra</n>
    <n>determinatio</n>
    <n>ad-rationes-contra</n>
  </xsl:param>

  <xsl:template name="createStructureNumber">
    <xsl:variable name="ana-value" select="translate(@ana, '#', '')"/>
    <!--
        1. if p.type
        type-name = p@type.value
        1.1 if p.n (= subsection)
        section-number = p@n.value
        2. elif parent::div@type and current p = first p in div
        type-name = parent::div@type.value
        2.1 if parent::div@n
        section-number = parent::div@n.value
    -->
    <xsl:choose>
      <xsl:when test="$ana-value = $structure-types/*">
        <xsl:choose>
          <xsl:when test="@n">
            <xsl:call-template name="printStructureNumber">
              <xsl:with-param name="type-name" select="$ana-value"/>
              <xsl:with-param name="section-number" select="@n"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="printStructureNumber">
              <xsl:with-param name="type-name" select="$ana-value"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="(parent::div[1]/translate(@ana, '#', '') = $structure-types/*) and
                      (position() = 1)">
        <xsl:choose>
          <xsl:when test="parent::div[1]/@n">
            <xsl:call-template name="printStructureNumber">
              <xsl:with-param name="type-name"
                              select="parent::div[1]/translate(@ana, '#', '')"/>
              <xsl:with-param name="section-number" select="parent::div[1]/@n"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="printStructureNumber">
              <xsl:with-param name="type-name"
                              select="parent::div[1]/translate(@ana, '#', '')"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- No structure number should be printed, so just make a linebreak -->
      <xsl:otherwise>
        <xsl:text>&#xa;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="printStructureNumber">
    <xsl:param name="type-name"/>
    <xsl:param name="section-number"/>
    <xsl:text>
    \no{</xsl:text>
    <xsl:choose>
      <xsl:when test="$type-name = 'rationes-principales-pro'">
        <xsl:text>2</xsl:text>
      </xsl:when>
      <xsl:when test="$type-name = 'rationes-principales-contra'">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:when test="$type-name = 'determinatio'">
        <xsl:text>3</xsl:text>
      </xsl:when>
      <xsl:when test="$type-name = 'ad-rationes-contra'">
        <xsl:text>Ad 1</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:if test="$section-number">
      <xsl:text>.</xsl:text>
      <xsl:value-of select="$section-number"/>
    </xsl:if>
    <xsl:text>}
    </xsl:text>
  </xsl:template>

</xsl:stylesheet>
