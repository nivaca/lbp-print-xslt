<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:my="local functions">

  <xsl:function name="my:format-lemma">
    <xsl:param name="text"/>
    <xsl:value-of select="normalize-space(lower-case($text))"/>
  </xsl:function>

  <!-- THE APPARATUS HANDLING -->
  <xsl:template match="app">
    <!-- First, check if we even need an apparatus entry: If the critical
         apparatus is disabled altogether or it's a spelling or insubstantial
         entry that is disabled, just print the content of the lem -->
    <xsl:choose>
      <xsl:when test="my:isfalse($create-critical-apparatus)">
        <xsl:apply-templates select="lem"/>
      </xsl:when>
      <xsl:when test="@type='variation-spelling'">
        <xsl:if test="my:istrue($ignore-spelling-variants)">
          <xsl:apply-templates select="lem"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>


        <!-- Two initial variables -->
        <!-- Store lemma text if it exists? -->
        <xsl:variable name="lemma_text">
          <xsl:choose>
            <xsl:when test="lem/cit[quote]">
              <xsl:value-of select="my:format-lemma(lem//quote[not(ancestor::bibl)])" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="lem[@n]">
                  <xsl:value-of select="my:format-lemma(lem/@n)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="my:format-lemma(string-join(.//lem//text()[not(ancestor::rdg)], ''))" />
                </xsl:otherwise>
              </xsl:choose>
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
          <xsl:when test="count(tokenize($lemma_text, ' ')) &gt; 4">
            <xsl:text>\lemma{</xsl:text>
            <xsl:value-of select="tokenize($lemma_text, ' ')[1]"/>
            <xsl:text> \dots{} </xsl:text>
            <xsl:value-of select="tokenize($lemma_text, ' ')[last()]"/>
            <xsl:text>}</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\lemma{\textnormal{</xsl:text>
            <xsl:value-of select="$lemma_text"/>
            <xsl:text>}}</xsl:text>
          </xsl:otherwise>
        </xsl:choose>

        <!-- Make an applabel if the app note has an xml:id -->
        <xsl:if test="@xml:id">
          <xsl:text>\applabel{</xsl:text>
          <xsl:value-of select="@xml:id"/>
          <xsl:text>}</xsl:text>
        </xsl:if>

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
               explicitly said to be identical with the @corresp='#lemma', AND the
               apparatus should be negative, it should not print the entry. It
               gives problems with additions, where the test on identity between
               lemma and reading returns true, but I don't what that (the
               reading contains an <add>. -->
          <xsl:if test="not($lemma_text = my:format-lemma(.) or @copyOf = 'preceding::lem')
                        or @type = 'correction-addition'
                        or my:istrue($positive-apparatus)">
            <xsl:call-template name="varianttype">
              <xsl:with-param name="preceding_word" select="$preceding_word"/>
              <xsl:with-param name="lemma_text" select="$lemma_text" />
              <xsl:with-param name="fromLemma">0</xsl:with-param>
            </xsl:call-template>
          </xsl:if>
        </xsl:for-each>

        <!-- Handling of apparatus notes. -->
        <!-- Test: If notes as included, and there is a note in the apparatus:
             either make a separate app entry (Cfootnote), if
             $app-notes-in-separate-apparatus is true, otherwise, just include it in
             the current app (Bfootnote).
             If there is no note, or they have been excluded, just close the app.
        -->
        <xsl:choose>
          <!-- First: is there any notes, and they are not excluded -->
          <xsl:when test="./note and my:istrue($include-app-notes)">

            <xsl:choose>
              <!-- Create separate note apparatus with Cfootnote -->
              <xsl:when test="my:istrue($app-notes-in-separate-apparatus)">
                <!-- Close current entry and create new. -->
                <xsl:text>}}</xsl:text>

                <!-- The critical text, which is always empty as we have already
                     made the text entry -->
                <xsl:text>\edtext{}{</xsl:text>

                <!-- The app lemma. Given in abbreviated or full length. -->
                <xsl:choose>
                  <xsl:when test="count(tokenize($lemma_text, ' ')) &gt; 4">
                    <xsl:text>\lemma{</xsl:text>
                    <xsl:value-of select="tokenize($lemma_text, ' ')[1]"/>
                    <xsl:text> \dots{} </xsl:text>
                    <xsl:value-of select="tokenize($lemma_text, ' ')[last()]"/>
                    <xsl:text>}</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>\lemma{</xsl:text>
                    <xsl:value-of select="$lemma_text"/>
                    <xsl:text>}</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>

                <!-- Notes in the apparatus are put as endnotes. If lemma is
                     empty, use the [nosep] option -->
                <xsl:choose>
                  <xsl:when test="lem = ''">
                    <xsl:text>\Aendnote[nosep]{</xsl:text>
                    <xsl:text> \emph{after} </xsl:text>
                    <xsl:value-of select="lem/@n"/>
                    <xsl:text>: </xsl:text>
                    <xsl:apply-templates select="note"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>\Aendnote{</xsl:text>
                    <xsl:apply-templates select="note"/>
                  </xsl:otherwise>
                </xsl:choose>

                <!-- Close the Aendnote -->
                <xsl:text>}}</xsl:text>
              </xsl:when>

              <!-- Don't make a separate apparatus -->
              <xsl:otherwise>
                <xsl:text>Note: </xsl:text>
                <xsl:apply-templates select="note"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>

          <!-- There is not note, or it is excluded, so we just close the Bfootnote -->
          <xsl:otherwise>
            <xsl:text>}}</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
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
        <xsl:if test="not($lemma_text = my:format-lemma(rdg))">
          <xsl:apply-templates select="."/>
        </xsl:if>
        <xsl:text> </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- variation-orthography -->
      <xsl:when test="@type = 'variation-orthography'">
        <xsl:if test="my:isfalse($ignore-spelling-variants)">
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
        <xsl:text>\emph{om.} </xsl:text>
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
            <xsl:if test="not($lemma_text = my:format-lemma(.))">
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
              <xsl:when test="not($lemma_text = my:format-lemma(add))">
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
          <!-- Wit is corrected to something identical to the lemma. -->
          <xsl:when test="$lemma_text = my:format-lemma(subst/add)">
            <xsl:apply-templates select="subst/del"/>
            <xsl:text> \emph{a.c.} </xsl:text>
          </xsl:when>
          <!-- Wit differs from lemma -->
          <xsl:otherwise>
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
          </xsl:otherwise>
        </xsl:choose>
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
            <xsl:choose>
              <xsl:when test="$lemma_text = my:format-lemma(subst/add)">
                <xsl:text> \emph{inv. a.c.} </xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="del/subst/add"/>
                <xsl:text> \emph{corr. ex} </xsl:text>
                <xsl:apply-templates select="del/subst/del"/>
              </xsl:otherwise>
            </xsl:choose>
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
          <!-- Otherwise, just print -->
          <xsl:otherwise>
            <xsl:apply-templates select="supplied/text()"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="@source">
          <xsl:text> \emph{suppl.}</xsl:text>
          <xsl:text> </xsl:text>
          <xsl:call-template name="get_witness_siglum"/>
        </xsl:if>
      </xsl:when>

      <!-- conjecture-removed -->
      <xsl:when test="@type = 'conjecture-removed'">
        <xsl:choose>
          <!-- empty lemma text handling -->
          <xsl:when test="$lemma_text = ''">
            <xsl:call-template name="process_empty_lemma_reading">
              <xsl:with-param name="reading_content" select="surplus/node()"/>
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
          <xsl:call-template name="get_witness_siglum"/>
        </xsl:if>
      </xsl:when>

      <!-- conjecture-corrected -->
      <xsl:when test="@type = 'conjecture-corrected'">
        <xsl:choose>
          <!-- If we come from lemma element, don't repeat the content -->
          <xsl:when test="$fromLemma = 1"/>
          <xsl:otherwise>
            <xsl:apply-templates select="corr"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="@source">
          <xsl:text> \emph{conj.} </xsl:text>
          <xsl:call-template name="get_witness_siglum"/>
          <xsl:text> </xsl:text>
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
  <xsl:template match="rdg//unclear"><xsl:apply-templates/> \emph{ut vid.}</xsl:template>

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
    <!-- First fill in witness references -->
    <xsl:variable name="witness-id" select="translate(@wit, '#', '')"/>
    <!-- Check for sibling witDetail elements and insert content -->
    <xsl:if test="following-sibling::witDetail[translate(@wit, '#', '')=$witness-id]">
      <xsl:text>\emph{</xsl:text>
      <xsl:apply-templates select="following-sibling::witDetail[translate(@wit, '#', '')=$witness-id]"/>
      <xsl:text>} </xsl:text>
    </xsl:if>
    <xsl:value-of select="translate(@wit, '#', '')"/>
    <xsl:text> </xsl:text>
    <!-- Then fill in other sources -->
    <xsl:variable name="source-id" select="translate(@source, '#', '')"/>
    <xsl:choose>
      <xsl:when test="//tei:bibl[@xml:id=$source-id]/@rend">
        <xsl:value-of select="//tei:bibl[@xml:id=$source-id]/@rend"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$source-id"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test=".//@hand">
      <xsl:text>\hand{</xsl:text>
      <xsl:for-each select=".//@hand">
        <xsl:value-of select="translate(., '#', '')"/>
        <xsl:if test="not(position() = last())">, </xsl:if>
      </xsl:for-each>
      <xsl:text>}</xsl:text>
    </xsl:if>
    <xsl:if test="my:istrue($apparatus-numbering)">
      <xsl:text> n</xsl:text><xsl:value-of select="$appnumber"></xsl:value-of>
    </xsl:if>
    <xsl:if test="following-sibling::*[1][self::rdg]">
      <xsl:value-of select="$app-entry-separator"/>
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
      <xsl:when test="add/@place='above-line'">
        <xsl:text> \emph{sup. lin.}</xsl:text>
      </xsl:when>
      <xsl:when test="contains(add/@place, 'margin')">
        <xsl:text> \emph{in marg.}</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
