<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">

  <!-- Variables from XML teiHeader -->
  <xsl:param name="apploc"><xsl:value-of select="/TEI/teiHeader/encodingDesc/variantEncoding/@location"/></xsl:param>
  <xsl:param name="notesloc"><xsl:value-of select="/TEI/teiHeader/encodingDesc/variantEncoding/@location"/></xsl:param>
  <xsl:variable name="title"><xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title"/></xsl:variable>
  <xsl:variable name="author"><xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/author"/></xsl:variable>
  <xsl:variable name="editor"><xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/editor"/></xsl:variable>
  <xsl:variable name="witness"><xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/listWit/witness"/></xsl:variable>
  <xsl:param name="targetdirectory">null</xsl:param>

  <!-- get versioning numbers -->
  <xsl:param name="sourceversion"><xsl:value-of select="/TEI/teiHeader/fileDesc/editionStmt/edition/@n"/></xsl:param>

  <!-- this xsltconvnumber should be the same as the git tag, and for any commit past the tag should be the tag name plus '-dev' -->
  <xsl:param name="conversionversion">dev</xsl:param>

  <!-- combined version number should have mirror syntax of an equation x+y source+conversion -->
  <xsl:variable name="combinedversionnumber"><xsl:value-of select="$sourceversion"/>+<xsl:value-of select="$conversionversion"/></xsl:variable>
  <!-- end versioning numbers -->

  <!-- Processing variables -->
  <xsl:variable name="fs"><xsl:value-of select="/TEI/text/body/div/@xml:id"/></xsl:variable>
  <xsl:variable name="name-list-file">../../lists/prosopography.xml</xsl:variable>
  <xsl:variable name="work-list-file">../../lists/workscited.xml</xsl:variable>

  <!-- BEGIN: Document configuration -->
  <!-- Variables -->
  <xsl:variable name="app_entry_separator">;</xsl:variable>
  <xsl:variable name="starts_on" select="/TEI/text/front/div/pb"/>

  <!-- Apparatus switches -->
  <xsl:variable name="ignoreSpellingVariants" select="true()"/>
  <xsl:variable name="ignoreInsubstantialEntries" select="true()"/>
  <xsl:variable name="positiveApparatus" select="false()"/>
  <xsl:variable name="apparatusNumbering" select="false()"/>

  <!-- Diplomatic switches -->
  <xsl:variable name="includeLinebreaks" select="false()"/>
  <xsl:variable name="normalizeSpelling" select="true()"/>
  <!-- END: Document configuration -->

  <xsl:output method="text" indent="no"/>
  <xsl:strip-space elements="div"/>
  <!-- <xsl:preserve-space elements="seg supplied"/> -->
  <!-- <xsl:template match="text()"> -->
  <!--     <xsl:value-of select="normalize-space(.)"/> -->
  <!-- </xsl:template> -->
  <xsl:template match="text()">
      <xsl:value-of select="replace(., '\s+', ' ')"/>
  </xsl:template>

  <xsl:template match="/">
    %this tex file was auto produced from TEI by lombardpress-print on <xsl:value-of select="current-dateTime()"/> using the  <xsl:value-of select="base-uri(document(''))"/>
    \documentclass[twoside, openright, a4paper]{scrbook}

    %imakeidx must be loaded beore eledmac
    \usepackage{imakeidx}
    \usepackage{titlesec}
    \usepackage{libertine}

    \usepackage [autostyle, english = american]{csquotes}
    \usepackage{reledmac}

    \usepackage{geometry}
    \geometry{left=4cm, right=4cm, top=3cm, bottom=3cm}

    \usepackage{fancyhdr}
    %fancyheading settings
    \pagestyle{fancy}

    %latin language
    \usepackage{polyglossia}
    \setmainlanguage{latin}

    %git package
    \usepackage{gitinfo2}


    %title settings
    \titleformat{\section} {\normalfont\scshape}{\thesection}{1em}{}
    \titleformat{\chapter} {\normalfont\large\scshape}{\thechapter}{50pt}{}

    %reledmac settings
    \Xinplaceoflemmaseparator{0pt}     % Don't add space after nolemma notes
    <!-- \Xarrangement{paragraph}           % Arrange all apparatuses in paragraphs -->
    \linenummargin{outer}
    \sidenotemargin{inner}

    %other settings
    \linespread{1.1}

    %custom macros
    \newcommand{\name}[1]{\textsc{#1}}
    \newcommand{\worktitle}[1]{\textit{#1}}
    \newcommand{\supplied}[1]{\{#1\}}
    \newcommand{\secluded}[1]{{[}#1{]}}
    \newcommand{\hand}[1]{\textsuperscript{#1}}
    \newcommand{\del}[1]{[#1 del. ms]}
    \newcommand{\no}[1]{\emph{#1}\quad}
    \newcommand{\MSlinebreak}{}

    % custom headings
    \newcommand{\customsection}[1]{{\large\itshape #1}}


    \begin{document}
    \fancyhead{}
    \fancyfoot{}
    \fancyhead[R]{<xsl:value-of select="$title"/>}
    \fancyhead[L]{<xsl:value-of select="$author"/>}
    <xsl:if test="/TEI/teiHeader/revisionDesc/@status = 'draft'">
      \fancyhead[C]{DRAFT}
    </xsl:if>

    \chapter*{<xsl:value-of select="$author"/>: <xsl:value-of select="$title"/>}
    \addcontentsline{toc}{chapter}{<xsl:value-of select="$title"/>}
    \section*{<xsl:value-of select="$witness"/>}

    <xsl:apply-templates select="//body"/>
    \end{document}
  </xsl:template>

  <xsl:template match="div//head">
    <xsl:text>\pstart&#xa;\eledsection*{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}&#xa;\pend&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="div//div">
    \bigskip
    <xsl:apply-templates/>

  </xsl:template>
  <xsl:template match="p">
    <xsl:variable name="pn"><xsl:number level="any" from="tei:text"/></xsl:variable>
    <xsl:text>&#xa;\pstart</xsl:text>
    <xsl:call-template name="createLabelFromId">
      <xsl:with-param name="labelType">start</xsl:with-param>
    </xsl:call-template>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates/>
    <xsl:call-template name="createLabelFromId">
      <xsl:with-param name="labelType">end</xsl:with-param>
    </xsl:call-template>
    <xsl:text>&#xa;\pend&#xa;</xsl:text>
  </xsl:template>
  <xsl:template match="head">
  </xsl:template>
  <xsl:template match="div">
    \beginnumbering
    <xsl:apply-templates/>
    \endnumbering
  </xsl:template>

  <!-- Normalization template -->
  <xsl:template match="choice/orig">
    <xsl:choose>
      <xsl:when test="$normalizeSpelling">
        <xsl:value-of select="./reg"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="./orig"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="unclear">\emph{<xsl:apply-templates/> [?]}</xsl:template>
  <xsl:template match="app//unclear"><xsl:apply-templates/> ut vid.</xsl:template>
  <xsl:template match="q | term">\emph{<xsl:apply-templates/>}</xsl:template> <!-- Does not work in app! -->
  <xsl:template match="pb | cb"><xsl:variable name="MsI"><xsl:value-of select="translate(./@ed, '#', '')"/></xsl:variable> |\ledsidenote{<xsl:value-of select="concat($MsI, ./@n)"/>} </xsl:template>
  <xsl:template match="lb">
    <xsl:choose>
      <xsl:when test="$includeLinebreaks">
        <xsl:text>\MSlinebreak{}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="supplied">\supplied{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="secl">\secluded{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="note">\footnoteA{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="del">\del{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="add">[+ <xsl:apply-templates/>, <xsl:value-of select="@place"/>]</xsl:template>
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
  <xsl:template match="cit[bibl]">
    <xsl:choose>
      <xsl:when test="./quote">
        <xsl:text>\edtext{\enquote{</xsl:text>
        <xsl:apply-templates select="quote"/>
        <xsl:text>}}{</xsl:text>
        <xsl:if test="count(tokenize(normalize-space(ref), ' ')) &gt; 4">
          <xsl:text>\lemma{</xsl:text>
          <xsl:value-of select="tokenize(normalize-space(ref), ' ')[1]"/>
          <xsl:text> \dots{} </xsl:text>
          <xsl:value-of select="tokenize(normalize-space(ref), ' ')[last()]"/>
          <xsl:text>}</xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:when test="./ref">
        <xsl:text>\edtext{</xsl:text>
        <xsl:apply-templates select="ref"/>
        <xsl:text>}{</xsl:text>
        <xsl:if test="count(tokenize(normalize-space(ref), ' ')) &gt; 4">
          <xsl:text>\lemma{</xsl:text>
          <xsl:value-of select="tokenize(normalize-space(ref), ' ')[1]"/>
          <xsl:text> \dots{} </xsl:text>
          <xsl:value-of select="tokenize(normalize-space(ref), ' ')[last()]"/>
          <xsl:text>}</xsl:text>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
    <xsl:text>\Afootnote{</xsl:text>
    <xsl:apply-templates select="bibl"/>
    <xsl:text>}}</xsl:text>
  </xsl:template>
  <xsl:template match="ref[bibl]">
    <xsl:text>\edtext{</xsl:text>
    <xsl:apply-templates select="seg"/>
    <xsl:text>}{</xsl:text>
    <xsl:if test="count(tokenize(normalize-space(./seg), ' ')) &gt; 10">
      <xsl:text>\lemma{</xsl:text>
      <xsl:value-of select="tokenize(normalize-space(./seg), ' ')[1]"/>
      <xsl:text> \dots\ </xsl:text>
      <xsl:value-of select="tokenize(normalize-space(./seg), ' ')[last()]"/>
      <xsl:text>}</xsl:text>
    </xsl:if>
    <xsl:text>\Afootnote{</xsl:text>
    <xsl:apply-templates select="bibl"/>
    <xsl:text>}}</xsl:text>
  </xsl:template>
  <xsl:template match="ref"><xsl:apply-templates/></xsl:template>

  <xsl:template name="substring-after-last">
    <!-- Based on XSLT Cookbook p. 28-31 -->
    <xsl:param name="input"/>
    <xsl:param name="substr"/>

    <!-- Get string that follows first occurrence -->
    <xsl:variable name="temp" select="substring-after($input, $substr)"/>

    <xsl:choose>
      <!-- If it still contains the search string, continue recursively -->
      <xsl:when test="$substr and contains($temp, $substr)">
        <xsl:call-template name="substring-after-last">
          <xsl:with-param name="input" select="$temp"/>
          <xsl:with-param name="substr" select="$substr"/>
        </xsl:call-template>
      </xsl:when>
      <!-- Else, return the temporary string, as it comes after last instance of
           the string we were looking for -->
      <xsl:otherwise>
        <xsl:value-of select="$temp"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- The apparatus template -->
  <xsl:template match="app">
    <xsl:variable name="preceding-tokens" select="tokenize(normalize-space(substring(string-join(preceding::text(), ''), string-length(string-join(preceding::text(), '')) - 100)), ' ')" />
    <xsl:variable name="lemmaContent">
      <xsl:choose>
        <xsl:when test="./lem and not(./lem = '')">1</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:text>\edtext{</xsl:text>
    <xsl:apply-templates select="lem"/>
    <xsl:text>}{</xsl:text>
    <xsl:choose>
      <xsl:when test="count(tokenize(normalize-space(./lem), ' ')) &gt; 10">
        <xsl:text>\lemma{</xsl:text>
        <xsl:value-of select="tokenize(normalize-space(./lem), ' ')[1]"/>
        <xsl:text> \dots\ </xsl:text>
        <xsl:value-of select="tokenize(normalize-space(./lem), ' ')[last()]"/>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\lemma{</xsl:text>
        <xsl:apply-templates select="lem"/>
        <xsl:text>}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="$lemmaContent = 1">
        <xsl:text>\Bfootnote{</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\Bfootnote[nosep]{</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:for-each select="./rdg">
      <xsl:call-template name="varianttype">
        <xsl:with-param name="precedingWord" select="$preceding-tokens[last()]" />
      </xsl:call-template>
    </xsl:for-each>
    <xsl:if test="./note">
      <xsl:text> Note: </xsl:text><xsl:value-of select="normalize-space(note)"/>
    </xsl:if>
    <xsl:text>}}</xsl:text>
  </xsl:template>


  <xsl:template match="name">
    <xsl:variable name="nameid" select="substring-after(./@ref, '#')"/>
    <xsl:text> \name{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text><xsl:text>\index[persons]{</xsl:text><xsl:value-of select="document($name-list-file)//tei:person[@xml:id=$nameid]/tei:persName[1]"/><xsl:text>}</xsl:text>
  </xsl:template>
  <xsl:template match="title">
    <xsl:variable name="workid" select="substring-after(./@ref, '#')"/>
    <xsl:text>\worktitle{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text><xsl:text>\index[works]{</xsl:text><xsl:value-of select="document($work-list-file)//tei:bibl[@xml:id=$workid]/tei:title[1]"/><xsl:text>}</xsl:text>
  </xsl:template>
  <xsl:template match="mentioned">
    <xsl:text>\enquote*{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="quote"><xsl:apply-templates/></xsl:template>
  <xsl:template match="rdg"></xsl:template>
  <xsl:template match="app/note"></xsl:template>


  <xsl:template name="varianttype">
    <xsl:param name="precedingWord" />
    <xsl:choose>
      <xsl:when test="./del">
        <xsl:value-of select="./del"/>
        <xsl:text> \emph{post} </xsl:text>
        <xsl:value-of select="$precedingWord"/>
        <xsl:text> \emph{del.} </xsl:text>
        <xsl:call-template name="getWitSiglum"/>
      </xsl:when>
      <xsl:when test="./add">
        <xsl:value-of select="./add"/>
        <xsl:call-template name="getLocation" />
        <xsl:text> \emph{add.} </xsl:text>
        <xsl:call-template name="getWitSiglum"/>
      </xsl:when>
      <xsl:when test="./space">
        <xsl:text>\emph{post} </xsl:text>
        <xsl:value-of select="$precedingWord"/>
        <xsl:text> \emph{vac. </xsl:text>
        <xsl:call-template name="getExtent" />
        <xsl:text>} </xsl:text>
        <xsl:call-template name="getWitSiglum"/>
      </xsl:when>
      <xsl:when test="./subst">
        <xsl:value-of select="./subst/add"/>
        <xsl:text> \emph{corr. ex} </xsl:text>
        <xsl:value-of select="./subst/del"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="getWitSiglum"/>
      </xsl:when>
      <xsl:when test="./unclear/@reason = 'rasura'">
        <xsl:text>\emph{post} </xsl:text>
        <xsl:value-of select="$precedingWord"/>
        <xsl:text> \emph{ras. </xsl:text>
        <xsl:call-template name="getExtent" />
        <xsl:text> litteras} </xsl:text>
        <xsl:call-template name="getWitSiglum"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/><xsl:text> </xsl:text>
        <xsl:call-template name="getWitSiglum"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="./note">
      <xsl:text> (</xsl:text><xsl:value-of select="normalize-space(./note)"/><xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="getExtent">
    <xsl:value-of select=".//@extent" />
    <xsl:choose>
      <xsl:when test=".//@extent &lt; 1">
        <xsl:choose>
          <xsl:when test=".//@unit = 'chars'"> litteram</xsl:when>
          <xsl:when test=".//@unit = 'words'"> verbum</xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test=".//@unit = 'chars'"> litteras</xsl:when>
          <xsl:when test=".//@unit = 'words'"> verba</xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>



  <xsl:template name="getLocation">
    <xsl:choose>
      <xsl:when test="./add/@place='above'">
        <xsl:text> \textit{sup. lin.}</xsl:text>
      </xsl:when>
      <xsl:when test="contains(./add/@place, 'margin')">
        <xsl:text> \textit{in marg.}</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="createLabelFromId">
    <xsl:param name="labelType" />
    <xsl:if test="@xml:id">
      <xsl:choose>
        <xsl:when test="$labelType='start'">
          <xsl:text>\edlabelS{</xsl:text>
          <xsl:value-of select="@xml:id"/>
          <xsl:text>}</xsl:text>
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

  <xsl:template name="getWitSiglum">
    <xsl:variable name="appnumber"><xsl:number level="any" from="tei:text"/></xsl:variable>
    <xsl:if test=".//unclear">
      <xsl:text>\emph{ut vid.} </xsl:text>
    </xsl:if>
    <xsl:value-of select="translate(./@wit, '#', '')"/>
    <xsl:if test=".//@hand">
      <xsl:text>\hand{</xsl:text>
      <xsl:for-each select=".//@hand">
        <xsl:value-of select="translate(., '#', '')"/>
        <xsl:if test="not(position() = last())">, </xsl:if>
      </xsl:for-each>
      <xsl:text>}</xsl:text>
    </xsl:if>

    <xsl:text> n</xsl:text><xsl:value-of select="$appnumber"></xsl:value-of>
  </xsl:template>

</xsl:stylesheet>
