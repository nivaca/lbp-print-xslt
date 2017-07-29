<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:my="local functions">

  <xsl:import href="modules/critical/preamble.xsl"/>
  <xsl:import href="modules/critical/apparatus.xsl"/>
  <xsl:import href="modules/critical/inline-elements.xsl"/>
  <xsl:import href="modules/critical/block-elements.xsl"/>
  <xsl:import href="modules/critical/references.xsl"/>
  <xsl:import href="modules/critical/translation.xsl"/>

  <!-- Variables from XML teiHeader -->
  <xsl:param name="apploc"><xsl:value-of select="/TEI/teiHeader/encodingDesc/variantEncoding/@location"/></xsl:param>
  <xsl:param name="notesloc"><xsl:value-of select="/TEI/teiHeader/encodingDesc/variantEncoding/@location"/></xsl:param>
  <xsl:variable name="title"><xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title"/></xsl:variable>
  <xsl:variable name="author"><xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/author"/></xsl:variable>
  <xsl:variable name="editor"><xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/editor"/></xsl:variable>

  <!-- get versioning numbers -->
  <xsl:param name="sourceversion"><xsl:value-of select="/TEI/teiHeader/fileDesc/editionStmt/edition/@n"/></xsl:param>

  <!-- this xsltconvnumber should be the same as the git tag, and for any commit past the tag should be the tag name plus '-dev' -->
  <xsl:param name="conversionversion">dev</xsl:param>

  <!-- combined version number should have mirror syntax of an equation x+y source+conversion -->
  <xsl:variable name="combinedversionnumber"><xsl:value-of select="$sourceversion"/>+<xsl:value-of select="$conversionversion"/></xsl:variable>
  <!-- end versioning numbers -->

  <!-- BEGIN: Document configuration -->
  <!-- Variables -->
  <xsl:variable name="starts_on" select="/TEI/text/front/div/pb"/>

  <!-- Command line parameters -->
  <xsl:param name="name-list-file">../../lists/prosopography.xml</xsl:param>
  <xsl:param name="work-list-file">../../lists/workscited.xml</xsl:param>
  <xsl:param name="app-entry-separator">;</xsl:param>
  <xsl:param name="font-size">12</xsl:param>
  <xsl:param name="ignore-spelling-variants">no</xsl:param>
  <xsl:param name="positive-apparatus">no</xsl:param>
  <xsl:param name="create-critical-apparatus">yes</xsl:param>
  <xsl:param name="apparatus-numbering">no</xsl:param>
  <xsl:param name="parallel-translation">no</xsl:param>
  <xsl:param name="app-fontium-quote">no</xsl:param>
  <xsl:param name="include-app-notes">no</xsl:param>
  <xsl:param name="app-notes-in-separate-apparatus">yes</xsl:param>
  <xsl:param name="standalone-document">yes</xsl:param>

  <!--
      Boolean check lists.
      To make command line parameters more robust, we check whether the value
      passed is one of the possible true or false values defined in these two
      lists with the test "parameter-name = boolean-true/*" (or boolean-false)
      if we test for false value.
  -->
  <xsl:variable name="boolean-true">
    <n>yes</n>
    <n>true</n>
    <n>1</n>
  </xsl:variable>

  <xsl:variable name="boolean-false">
    <n>no</n>
    <n>true</n>
    <n>0</n>
  </xsl:variable>

  <xsl:function name="my:istrue">
    <xsl:param name="parameter-name"/>
    <xsl:if test="lower-case($parameter-name) = $boolean-true/*">
      <xsl:value-of select="true()"/>
    </xsl:if>
  </xsl:function>

  <xsl:function name="my:isfalse">
    <xsl:param name="parameter-name"/>
    <xsl:if test="lower-case($parameter-name) = $boolean-false/*">
      <xsl:value-of select="true()"/>
    </xsl:if>
  </xsl:function>
  <!-- END: Document configuration -->

  <xsl:output method="text" indent="no"/>
  <xsl:strip-space elements="div"/>
  <xsl:template match="text()">
    <xsl:value-of select="replace(., '\s+', ' ')"/>
  </xsl:template>

  <xsl:variable name="text_language">
    <xsl:choose>
      <xsl:when test="//text[@xml:lang='la']">latin</xsl:when>
      <xsl:otherwise>english</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template match="body">
    <xsl:choose>
      <xsl:when test="my:istrue($parallel-translation)">
        \begin{pages}
        \begin{Leftside}
        <xsl:call-template name="documentDiv">
          <xsl:with-param name="content" select="//body/div" />
          <xsl:with-param name="inParallelText" select="false()"/>
        </xsl:call-template>
        \end{Leftside}

        \begin{Rightside}
        <xsl:call-template name="documentDiv">
          <xsl:with-param name="content" select="document($translationFile)//body/div" />
          <xsl:with-param name="inParallelText" select="true()"/>
        </xsl:call-template>
        \end{Rightside}
        \end{pages}
        \Pages
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
    <!-- Create endnotes (`<note>`s within `<app>`). -->
    <xsl:if test="my:istrue($include-app-notes) and
                  my:istrue($app-notes-in-separate-apparatus)">
      <xsl:text>
        \clearpage
        \section*{Critical apparatus notes}
        Format: \verb+n[-nn].x[-y]+ where \verb+n+ and \verb+nn+ = pagenumbers and verb+x+ and \verb+y+ =
        linenumbers. Content of brackets is optional.

        \doendnotes{A}
      </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="front/div">
    <xsl:apply-templates/>
  </xsl:template>

</xsl:stylesheet>
