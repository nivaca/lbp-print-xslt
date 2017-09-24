# LombardPress Print conversion scripts

This repository contains a xslt package for conversion
of [LombardPress Schema](http://lombardpress.org/schema/docs/) compliant TEI XML
transcriptions to TeX format. 

The [LombardPress print app](https://github.com/stenskjaer/lbp_print-web-app)
uses this package as its default conversion scripts.
Visit [print.lombardpress.org](http://print.lombardpress.org) to see it in
action.

## Packaging XSLT scripts

Anyone can create custom xslt-latex packages that can be used for this purpose.
The current repository is just an example of how it can be done.

This directory shows the expected structure of a package. It should be divided
in folders named for the version of the XML schema they are designed for, and
each folder should contain a file called critical.xslt or diplomatic.xslt (but
may also just contain either of those). It is strongly adviced also to include a
directory called `default` contained a script that can be used as a fallback. It
is probably a good idea to make this a copy of the highest supported version in
the package.

So for example, a package that supports LBP schema versions 0.0.0 and 1.0.0
would have this structure:
``` 
- 0.0.0
  - critical.xslt
  - diplomatic.xslt
- 1.0.0
  - critical.xslt
  - diplomatic.xslt
- default
  - critical.xslt     # identical with 1.0.0/critical.xslt
  - diplomatic.xslt   # identical with 1.0.0/diplomatic.xslt
- README.md
```

It is up to the package creator to decide how many different version of the LBP
schema should be supported. Obviously the higher version coverage a package has,
the more useful will it be to other editors than the author herself.

By ensuring that all packages have the same basic structure, it is easy to share
different conversion scripts across environments. It will also ensure that
different programmatic publication and processing workflows can make some basic
assumptions about the XSLT packages that are used, irrespective of where the
package comes from. 

## Representation and conversion

### Structural units and numbering

Important structural numbers should be computed and available for reference and
cross-reference that can be rendered in the resulting PDF.

The basic principle is to use `<div>`s inside the main containing `<div>`. Each
`<div>` below that indicate a structural group.

A structural type is given in the `@ana` attribute. The following are
recognized:
- rationes-principales
- rationes-principales-pro
- rationes-principales-contra
- determinatio
- ad-rationes


#### *Rationes principales*

- A `div` with the `@ana`-value `rationes-principales` indicate that the `div`
  contains *rationes principales*.
- Any subsequent `p` will be considered a single and complete *ratio*, unless it
  is contained in another `div` or it has the `@ana` attribute set to
  `structure-head`.
- Groups of `p`s contained by another `div` will together constitute a *ratio*.

Numbering:

- Sections of *rationes* will be numbered sequentially such that each `p` of
  child `div` of a `div[@ana='rationes-principales']` gets an incremented
  sub-number (e.g. "1.1", "1.2", "1.3" etc.).
- Any `p` with the `@ana` value `structure-head` will not get a sub-number.


## Contributing

Of course, pull requests or issue reports with this package are very welcome in
the [issue tracker](https://github.com/stenskjaer/lbp-print-xslt/issues).

If your produce your own package, please let is know and we will create a
package registry for public reference.
