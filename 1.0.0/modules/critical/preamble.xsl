<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:my="local functions">

  <xsl:template match="/">
    <xsl:if test="my:istrue($standalone-document)">
      %this tex file was auto produced from TEI by lombardpress-print on <xsl:value-of select="current-dateTime()"/> using the  <xsl:value-of select="base-uri(document(''))"/>
      \documentclass[a4paper, <xsl:value-of select="$font-size"/>pt]{book}

      % imakeidx must be loaded beore eledmac
      \usepackage{imakeidx}
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
      \usepackage{titlesec}
      \titleformat{\chapter}{\normalfont\large\scshape}{\thechapter}{50pt}{}
      \titleformat{\section}{\normalfont\scshape}{\thesection}{1em}{}
      \titleformat{\subsection}[block]{\centering\normalfont\itshape}{\thesubsection}{}{}
      \titlespacing*{\subsection}{20pt}{3.25ex plus 1ex minus .2 ex}{1.5ex plus .2ex}[20pt]

      % reledmac settings
      \usepackage[final]{reledmac}

      \Xinplaceoflemmaseparator{0pt} % Don't add space after nolemma notes.
      \Xlemmadisablefontselection[A] % In fontium lemmata, don't copy font formatting.
      \Xarrangement{paragraph}
      \linenummargin{outer}
      \sidenotemargin{inner}
      \lineation{page}

      \Xendbeforepagenumber{}
      \Xendafterpagenumber{.}
      \Xendlineprefixsingle{}
      \Xendlineprefixmore{}

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

      % Critical edition sections
      \usepackage{titlesec}
      \titleclass{\extrasection}{straight}[\section]
      \titleclass{\extrasubsection}{straight}[\subsection]
      \titleformat{\extrasection}[display]
      {\scshape\Large\fillast}
      {}
      {1ex minus .1ex}
      {}
      \titleformat{\extrasubsection}[display]
      {\itshape\large\fillast}
      {}
      {1ex minus .1ex}
      {}
      \titlespacing{\extrasection}{20pt}{*4}{*2}[20pt]
      \titlespacing*{\extrasubsection}{20pt}{*4}{*2}[20pt]
      \newcounter{extrasection}
      \newcounter{extrasubsection}

      <xsl:if test="my:istrue($parallel-translation)">
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
    </xsl:if>

    <xsl:apply-templates select="//body"/>

    <xsl:if test="my:istrue($standalone-document)">
      \end{document}
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
