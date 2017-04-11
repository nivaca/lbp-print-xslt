<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">

  <!-- Variables from XML teiHeader -->
  <xsl:param name="apploc"><xsl:value-of select="/TEI/teiHeader/encodingDesc/variantEncoding/@location"/></xsl:param>
  <xsl:param name="notesloc"><xsl:value-of select="/TEI/teiHeader/encodingDesc/variantEncoding/@location"/></xsl:param>
  <xsl:variable name="title"><xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title"/></xsl:variable>
  <xsl:variable name="author"><xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/author"/></xsl:variable>
  <xsl:variable name="editor"><xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/editor"/></xsl:variable>
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
  <xsl:variable name="font_size">11</xsl:variable>
  <xsl:variable name="starts_on" select="/TEI/text/front/div/pb"/>

  <!-- Boolean switches -->
  <xsl:variable name="ignoreSpellingVariants" select="true()"/>
  <xsl:variable name="ignoreInsubstantialEntries" select="true()"/>
  <xsl:variable name="positiveApparatus" select="false()"/>
  <xsl:variable name="apparatusNumbering" select="false()"/>
  <xsl:variable name="parallelTranslation" select="false()"/>
  <xsl:variable name="appFontiumQuote" select="false()"/>
  <!-- END: Document configuration -->

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

  <xsl:variable name="text_language">
    <xsl:choose>
      <xsl:when test="//text[@xml:lang='la']">latin</xsl:when>
      <xsl:otherwise>english</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>


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
\documentclass[a4paper, <xsl:value-of select="$font_size"/>pt]{book}

% imakeidx must be loaded beore eledmac
\usepackage{imakeidx}
\usepackage{titlesec}
\usepackage{libertine}
\usepackage{csquotes}

\usepackage{geometry}
\geometry{left=4cm, right=4cm, top=3cm, bottom=3cm}

\usepackage{fancyhdr}
% fancyheading settings
\pagestyle{fancy}

% latin language
\usepackage{polyglossia}
\setmainlanguage{english}
\setotherlanguage{latin}

% a critical mark
\usepackage{amssymb}

% git package
\usepackage{gitinfo2}


% title settings
\titleformat{\chapter}{\normalfont\large\scshape}{\thechapter}{50pt}{}
\titleformat{\section}{\normalfont\scshape}{\thesection}{1em}{}
\titleformat{\subsection}[block]{\centering\normalfont\itshape}{\thesubsection}{}{}
\titlespacing*{\subsection}{20pt}{3.25ex plus 1ex minus .2 ex}{1.5ex plus .2ex}[20pt]

% reledmac settings
\usepackage[final]{reledmac}

\Xinplaceoflemmaseparator{0pt} % Don't add space after nolemma notes
\Xarrangement{paragraph}
\linenummargin{outer}
\sidenotemargin{inner}
\lineation{page}

\Xendbeforepagenumber{p.~}
\Xendafterpagenumber{,}
\Xendlineprefixsingle{l.~}
\Xendlineprefixmore{ll.~}

\Xnumberonlyfirstinline[]
\Xnumberonlyfirstintwolines[]
\Xbeforenotes{\baselineskip}

% This should prevent overfull vboxes
\AtBeginDocument{\Xmaxhnotes{0.5\textheight}}
\AtBeginDocument{\maxhnotesX{0.5\textheight}}

\Xprenotes{\baselineskip}

\let\Afootnoterule=\relax
\let\Bfootnoterule=\relax

% other settings
\linespread{1.1}

<xsl:if test="$parallelTranslation">
  <xsl:text>
    % reledpar setup
    \usepackage{reledpar}
  </xsl:text>
</xsl:if>

% custom macros
\newcommand{\name}[1]{#1}
\newcommand{\lemmaQuote}[1]{\textsc{#1}}
\newcommand{\worktitle}[1]{\textit{#1}}
\newcommand{\supplied}[1]{⟨#1⟩} <!-- Previously I used ⟨#1⟩ -->
\newcommand{\suppliedInVacuo}[1]{$\ulcorner$#1$\urcorner$} <!-- Text added where witnes(es) preserve a space -->
\newcommand{\secluded}[1]{{[}#1{]}}
\newcommand{\metatext}[1]{&lt;#1&gt;}
\newcommand{\hand}[1]{\textsuperscript{#1}}
\newcommand{\del}[1]{[#1 del. ms]}
\newcommand{\no}[1]{\emph{#1}\quad}
\newcommand{\corruption}[1]{\textdagger#1\textdagger}

\begin{document}
\fancyhead{}
\fancyfoot[C]{\thepage}
\fancyhead[R]{<xsl:value-of select="$title"/>}
\fancyhead[L]{<xsl:value-of select="$author"/>}
<xsl:if test="/TEI/teiHeader/revisionDesc/@status = 'draft'">
  \fancyhead[C]{DRAFT}
</xsl:if>

\chapter*{<xsl:value-of select="$author"/>: <xsl:value-of select="$title"/>}
\addcontentsline{toc}{chapter}{<xsl:value-of select="$title"/>}

<xsl:apply-templates select="//body"/>
\end{document}
  </xsl:template>

  <xsl:template name="documentDiv">
    <xsl:param name="content"/>
    <xsl:param name="inParallelText"/>
    <xsl:apply-templates select="$content">
      <xsl:with-param name="inParallelText" select="$inParallelText"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="head">
    <xsl:if test="not(following-sibling::p)">
      \subsection*{<xsl:apply-templates />}
    </xsl:if>
  </xsl:template>

  <xsl:param name="structure-types">
    <n>rationes-principales-pro</n>
    <n>rationes-principales-contra</n>
    <n>determinatio</n>
    <n>ad-rationes-contra</n>
  </xsl:param>

  <xsl:template match="div[translate(@ana, '#', '') = $structure-types/*
                       and not(@n)]">
    <xsl:if test="not($parallelTranslation)">
      <!-- The parallel typesetting does not work well with manually added space
           because of syncronization -->
      <xsl:text>&#xa;\medbreak&#xa;</xsl:text>
    </xsl:if>
    <xsl:apply-templates />
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
        <xsl:text>\subsection*{</xsl:text>
        <xsl:apply-templates select="preceding-sibling::head/node()"/>
        <xsl:text>}</xsl:text>
      </xsl:if>
      <xsl:if test="((parent::div[1]/translate(@ana, '#', '') = $structure-types/*) and (position() = 1))">
        <xsl:text>\medbreak{}</xsl:text>
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
    <xsl:text>&#xa;</xsl:text>
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

  <xsl:template match="body">
    <xsl:choose>
      <xsl:when test="$parallelTranslation">
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
  </xsl:template>

  <xsl:template match="front/div">
    <xsl:apply-templates/>
  </xsl:template>

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
  <xsl:template match="note">\footnoteA{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="app/note"><xsl:apply-templates/></xsl:template>
  <xsl:template match="unclear">\emph{<xsl:apply-templates/> [?]}</xsl:template>
  <xsl:template match="desc">\emph{<xsl:apply-templates/>}</xsl:template>

  <xsl:template match="mentioned">\emph{<xsl:apply-templates/>}</xsl:template>
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
              <xsl:text>|</xsl:text>
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
                <xsl:text>|</xsl:text>
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

  <xsl:template match="cit">
    <xsl:text>\edtext{</xsl:text>
    <xsl:apply-templates select="ref"/>
    <xsl:apply-templates select="quote"/>
    <xsl:text>}</xsl:text>
    <xsl:text>{\lemma{</xsl:text>
    <xsl:if test="$appFontiumQuote">
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
      <xsl:when test="$appFontiumQuote">
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

  <!-- THE APPARATUS HANDLING -->
  <xsl:template match="app">
    <!-- First, check if it's a spelling entry and if they should be added -->
    <xsl:choose>
      <xsl:when test="@type='variation-spelling'">
        <xsl:if test="$ignoreSpellingVariants">
          <xsl:apply-templates select="lem"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="@type='insubstantial'">
        <xsl:if test="$ignoreInsubstantialEntries">
          <xsl:apply-templates select="lem"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>


        <!-- Two initial variables -->
        <!-- Store lemma text if it exists? -->
        <xsl:variable name="lemma_text">
          <xsl:choose>
            <xsl:when test="lem/cit/quote">
              <xsl:value-of select="lem/cit/quote" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space(./lem)" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!-- Register a possible text anchor (for empty lemmas) -->
        <xsl:variable name="preceding_word" select="lem/@n"/>


        <!-- The entry proper -->
        <!-- The critical text -->
        <xsl:text>\edtext{</xsl:text>
        <xsl:apply-templates select="lem"/>
        <xsl:text>}{</xsl:text>

        <!-- The app lemma. Given in abbreviated or full length. -->
        <xsl:choose>
          <xsl:when test="count(tokenize(normalize-space($lemma_text), ' ')) &gt; 4">
            <xsl:text>\lemma{</xsl:text>
            <xsl:value-of select="tokenize(normalize-space($lemma_text), ' ')[1]"/>
            <xsl:text> \dots{} </xsl:text>
            <xsl:value-of select="tokenize(normalize-space($lemma_text), ' ')[last()]"/>
            <xsl:text>}</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\lemma{</xsl:text>
            <xsl:value-of select="$lemma_text"/>
            <xsl:text>}</xsl:text>
          </xsl:otherwise>
        </xsl:choose>

        <!-- The critical note itself. If lemma is empty, use the [nosep] option -->
        <xsl:choose>
          <xsl:when test="lem = ''">
            <xsl:text>\Bfootnote[nosep]{</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\Bfootnote{</xsl:text>
          </xsl:otherwise>
        </xsl:choose>

        <!--
            This is the trick part. If we are actually in a <lem>-element instead of
            a <rdg>-element, it entails some changes in the handling of the
            apparatus note.
            We know that we are in a <lem>-element if it is given a reading type.
            TODO: This should check that it is one of the used reading types.
            TODO: Should all reading types be possible in the lemma? Any? It is
            implied by the possibility of having @wit in lemma.
        -->
        <xsl:if test="lem/@type">
          <!-- This loop is stupid, but I need to have the lem-element as the root
               node when handling the variants. -->
          <xsl:for-each select="./lem">
            <xsl:call-template name="varianttype">
              <xsl:with-param name="lemma_text" select="$lemma_text" />
              <xsl:with-param name="fromLemma">1</xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:if>
        <xsl:for-each select="rdg">
          <!-- This test is not good. Intention: If rdg = lemma, or it is
               explicitly said to be identical with the lemma with @ana, AND the
               apparatus should be negative, it should not print the entry. It
               gives problems with additions, where the test on identity between
               lemma and reading returns true, but I don't what that (the
               reading contains an <add>. -->
          <xsl:if test="not($lemma_text = normalize-space(.) or @ana = '#lemma')
                        or @type = 'correction-addition'
                        or $positiveApparatus">
            <xsl:call-template name="varianttype">
              <xsl:with-param name="preceding_word" select="$preceding_word"/>
              <xsl:with-param name="lemma_text" select="$lemma_text" />
              <xsl:with-param name="fromLemma">0</xsl:with-param>
            </xsl:call-template>
          </xsl:if>
        </xsl:for-each>

        <!-- The possibility of having a note for the whole app entry. -->
        <xsl:if test="./note">
          <xsl:apply-templates select="note"/>
        </xsl:if>

        <!-- Wrap up -->
        <xsl:text>}}</xsl:text>

      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="varianttype">
    <xsl:param name="lemma_text" />
    <xsl:param name="fromLemma" />
    <xsl:param name="preceding_word" />

    <xsl:choose>

      <!-- VARIATION READINGS -->
      <!-- variation-substance -->
      <xsl:when test="@type = 'variation-substance' or not(@type)">
        <xsl:if test="not($lemma_text = normalize-space(.))">
          <xsl:apply-templates select="."/>
        </xsl:if>
        <xsl:text> </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- variation-orthography -->
      <xsl:when test="@type = 'variation-orthography'">
        <xsl:if test="not($ignoreSpellingVariants)">
          <xsl:apply-templates select="."/>
          <xsl:text> </xsl:text>
          <xsl:call-template name="get_witness_siglum"/>
        </xsl:if>
      </xsl:when>

      <!-- variation-inversion -->
      <xsl:when test="@type = 'variation-inversion'">
        <xsl:choose>
          <xsl:when test="./seg">
            <xsl:apply-templates select="./seg[1]"/>
            <xsl:text> \emph{ante} </xsl:text>
            <xsl:apply-templates select="./seg[2]"/>
            <xsl:text> \emph{scr.} </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\emph{inv.} </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- variation-present -->
      <xsl:when test="@type = 'variation-present'">
        <xsl:choose>
          <xsl:when test="@cause = 'repetition'">
            <xsl:if test="not($lemma_text)">
              <!--
                  If there is no lemma (I think both might be intuitive to
                  different people), use the reading, which will be identical to
                  the preceding word, as it is an iteration
              -->
              <xsl:value-of select="."/>
            </xsl:if>
            <xsl:text> \emph{iter.} </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="process_empty_lemma_reading">
              <xsl:with-param name="reading_content" select="."/>
              <xsl:with-param name="preceding_word" select="$preceding_word"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- variation-absent -->
      <!-- TODO: Expand further in accordance with documentation -->
      <xsl:when test="@type = 'variation-absent'">
        <xsl:choose>
          <xsl:when test="./space">
            <xsl:text>\emph{spat. vac. </xsl:text>
            <!-- spatium vacuum. Full formula: "spatium vacuum NN litterarum
                 capax" or "spatium vacuum NN litterarum"-->
            <xsl:call-template name="getExtent"/>
            <xsl:if test="./space/@reason">
              <xsl:text> (</xsl:text>
              <xsl:value-of select="./space/@cause"/>
              <xsl:text>)</xsl:text>
            </xsl:if>
            <xsl:text>} </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\emph{om.} </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- variation-choice -->
      <!--
          TODO: This also needs implementation of hands, location and segment
          order. I thinks it better to start with a bare bones implementation
          and go from there
      -->
      <xsl:when test="@type = 'variation-choice'">
        <xsl:variable name="seg_count" select="count(choice/seg)"/>
        <xsl:for-each select="choice/seg">
          <xsl:choose>
            <xsl:when test="position() &lt; $seg_count">
              <xsl:choose>
                <xsl:when test="position() = ($seg_count - 1)">
                  <xsl:apply-templates select="."/>
                  <xsl:text> \emph{et} </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="."/>
                  <xsl:text>, </xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
        <xsl:text> </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- CORRECTIONS -->
      <!-- correction-addition -->
      <xsl:when test="@type = 'correction-addition'">
        <xsl:choose>
          <!-- addition made in <lem> element -->
          <xsl:when test="$fromLemma = 1">
            <xsl:if test="not($lemma_text = normalize-space(.))">
              <xsl:apply-templates select="."/>
            </xsl:if>
          </xsl:when>
          <!-- addition not in lemma element -->
          <xsl:otherwise>
            <xsl:choose>
              <!-- empty lemma text handling -->
              <xsl:when test="$lemma_text = ''">
                <xsl:call-template name="process_empty_lemma_reading">
                  <xsl:with-param name="reading_content" select="add"/>
                  <xsl:with-param name="preceding_word" select="$preceding_word"/>
                </xsl:call-template>
              </xsl:when>
              <!-- reading ≠ lemma -->
              <xsl:when test="not($lemma_text = normalize-space(add))">
                <xsl:apply-templates select="add"/>
              </xsl:when>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="getLocation" />
        <xsl:text> </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- manual -->
      <xsl:when test="@type = 'manual'">
        <xsl:apply-templates select="."/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>


      <!-- correction-deletion -->
      <!-- TODO: Implement handling of del@rend attribute -->
      <xsl:when test="@type = 'correction-deletion'">
        <xsl:call-template name="process_empty_lemma_reading">
          <xsl:with-param name="reading_content" select="del"/>
          <xsl:with-param name="preceding_word" select="$preceding_word"/>
        </xsl:call-template>
        <xsl:text> \emph{del.} </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- correction-substitution -->
      <!-- TODO: Take @rend and @place into considerations -->
      <xsl:when test="@type = 'correction-substitution'">
        <xsl:choose>
          <!-- empty lemma text handling -->
          <xsl:when test="$lemma_text = ''">
            <xsl:call-template name="process_empty_lemma_reading">
              <xsl:with-param name="reading_content" select="subst/add"/>
              <xsl:with-param name="preceding_word" select="$preceding_word"/>
            </xsl:call-template>
          </xsl:when>
          <!-- lemma has content -->
          <xsl:otherwise>
            <xsl:apply-templates select="subst/add"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> \emph{corr. ex} </xsl:text>
        <xsl:apply-templates select="subst/del"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- correction-transposition -->
      <xsl:when test="@type = 'correction-transposition'">
        <xsl:choose>
          <xsl:when test="subst/del/seg[@n]">
            <xsl:apply-templates select="subst/del/seg[@n = 1]"/>
            <xsl:text> \emph{ante} </xsl:text>
            <xsl:apply-templates select="subst/del/seg[@n = 2]"/>
            <xsl:text> \emph{transp.} </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="tokenize(normalize-space(subst/del), ' ')[1]"/>
            <xsl:text> \emph{ante} </xsl:text>
            <xsl:value-of select="tokenize(normalize-space(subst/del), ' ')[last()]"/>
            <xsl:text> \emph{transp.} </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- correction-cancellation subtypes -->
      <!-- TODO: They need to handle hands too -->

      <!-- deletion-of-addition -->
      <xsl:when test="@type = 'deletion-of-addition'">
        <xsl:call-template name="process_empty_lemma_reading">
          <xsl:with-param name="reading_content" select="del/add"/>
          <xsl:with-param name="preceding_word" select="$preceding_word"/>
        </xsl:call-template>
        <xsl:text> \emph{add. et del.} </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- deleton-of-deletion -->
      <xsl:when test="@type = 'deletion-of-deletion'">
        <xsl:apply-templates select="del/del"/>
        <xsl:text> \emph{del. et scr.} </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- deletion-of-substitution -->
      <xsl:when test="@type = 'deletion-of-substitution'">
        <xsl:apply-templates select="del/subst/add"/>
        <xsl:text> \emph{corr. ex} </xsl:text>
        <xsl:apply-templates select="del/subst/del"/>
        <xsl:text> \emph{et deinde correctionem revertavit} </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- substitution-of-addition -->
      <xsl:when test="@type = 'substitution-of-addition'">
        <xsl:apply-templates select="subst/del/add"/>
        <xsl:text> \emph{add. et del. et deinde} </xsl:text>
        <xsl:apply-templates select="subst/add"/>
        <xsl:text> \emph{scr.} </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- CONJECTURES -->
      <!-- conjecture-supplied -->
      <xsl:when test="@type = 'conjecture-supplied'">
        <xsl:choose>
          <!-- If we come from lemma element, don't print the content of it -->
          <xsl:when test="$fromLemma = 1"/>
          <xsl:otherwise>
            <xsl:apply-templates select="supplied"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="@source">
          <xsl:text> \emph{suppl.}</xsl:text>
          <xsl:text> </xsl:text>
          <xsl:value-of select="@source"/>
          <xsl:if test="following-sibling::*">
            <xsl:value-of select="$app_entry_separator"/>
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:if>
      </xsl:when>

      <!-- conjecture-removed -->
      <xsl:when test="@type = 'conjecture-removed'">
        <xsl:choose>
          <!-- empty lemma text handling -->
          <xsl:when test="$lemma_text = ''">
            <xsl:call-template name="process_empty_lemma_reading">
              <xsl:with-param name="reading_content" select="surplus"/>
              <xsl:with-param name="preceding_word" select="$preceding_word"/>
            </xsl:call-template>
          </xsl:when>
          <!-- If we come from lemma element, don't print the content of it -->
          <xsl:when test="$fromLemma = 1"/>
          <xsl:otherwise>
            <xsl:apply-templates select="supplied"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> \emph{secl.}</xsl:text>
        <xsl:if test="@source">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@source"/>
        </xsl:if>
        <xsl:if test="following-sibling::*">
          <xsl:value-of select="$app_entry_separator"/>
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:when>

      <!-- conjecture-corrected -->
      <xsl:when test="@type = 'conjecture-corrected'">
        <xsl:choose>
          <!-- If we come from lemma element, don't repeat the content -->
          <xsl:when test="$fromLemma = 1"/>
          <xsl:otherwise>
            <xsl:apply-templates select="."/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="@source">
          <xsl:text> \emph{conj.} </xsl:text>
          <xsl:value-of select="@source"/>
          <xsl:text> </xsl:text>
          <xsl:if test="following-sibling::*">
            <xsl:value-of select="$app_entry_separator"/>
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:if>
      </xsl:when>

      <xsl:otherwise>
        <xsl:apply-templates select="."/><xsl:text> </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="note">
      <xsl:text> (</xsl:text>
      <xsl:apply-templates select="note"/>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- READING TEMPLATES -->
  <!-- Erasures in readings -->
  <!-- <xsl:template match="rdg/space[@reason = 'erasure']"> -->
  <!--   <xsl:text>\emph{ras.</xsl:text> -->
  <!--   <xsl:if test="@extent"> -->
  <!--     <xsl:text> </xsl:text> -->
  <!--     <xsl:call-template name="getExtent"/> -->
  <!--   </xsl:if> -->
  <!--   <xsl:text>}</xsl:text> -->
  <!-- </xsl:template> -->

  <!-- Unclear in readings adds an "ut vid." to the note -->
  <xsl:template match="rdg/unclear"><xsl:apply-templates/> \emph{ut vid.}</xsl:template>

  <!-- APPARATUS HELPER TEMPLATES -->
  <xsl:template name="process_empty_lemma_reading">
    <xsl:param name="reading_content"/>
    <xsl:param name="preceding_word"/>
    <xsl:value-of select="$reading_content"/>
    <xsl:text> \emph{post} </xsl:text>
    <xsl:value-of select="$preceding_word"/>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template name="get_witness_siglum">
    <xsl:variable name="appnumber"><xsl:number level="any" from="tei:text"/></xsl:variable>
    <!-- Check for sibling witDetail elements and insert content -->
    <xsl:if test="following-sibling::witDetail">
      <xsl:text>\emph{</xsl:text>
      <xsl:value-of select="following-sibling::witDetail"/>
      <xsl:text>} </xsl:text>
    </xsl:if>
    <!-- Move on with the siglum itself -->
    <xsl:value-of select="translate(./@wit, '#', '')"/>
    <xsl:if test=".//@hand">
      <xsl:text>\hand{</xsl:text>
      <xsl:for-each select=".//@hand">
        <xsl:value-of select="translate(., '#', '')"/>
        <xsl:if test="not(position() = last())">, </xsl:if>
      </xsl:for-each>
      <xsl:text>}</xsl:text>
    </xsl:if>
    <xsl:if test="$apparatusNumbering">
      <xsl:text> n</xsl:text><xsl:value-of select="$appnumber"></xsl:value-of>
    </xsl:if>
    <xsl:if test="following-sibling::* and not(following-sibling::witDetail)">
      <xsl:value-of select="$app_entry_separator"/>
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="getExtent">
    <xsl:value-of select=".//@extent" />
    <xsl:choose>
      <xsl:when test=".//@extent &lt; 2">
        <xsl:choose>
          <xsl:when test=".//@unit = 'letters'"> litt.</xsl:when>
          <xsl:when test=".//@unit = 'words'"> verb.</xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test=".//@unit = 'letters'"> litt.</xsl:when>
          <xsl:when test=".//@unit = 'words'"> verb.</xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="getLocation">
    <xsl:choose>
      <xsl:when test="add/@place='above'">
        <xsl:text> \emph{sup. lin.}</xsl:text>
      </xsl:when>
      <xsl:when test="contains(add/@place, 'margin')">
        <xsl:text> \emph{in marg.}</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
