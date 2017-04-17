# LombardPress Print conversion scripts

This repository contains a xslt package for conversion
of [LombardPress Schema](http://lombardpress.org/schema/docs/) compliant TEI XML
transcriptions to TeX format. 

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
