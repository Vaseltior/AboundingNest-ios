#!/bin/sh

######################
# Clean the existing docs.
rm -rf docs/docs

/usr/local/bin/appledoc \
--project-name AboundingNest \
--project-version 1.0 \
--project-company Samuel Grau \
--company-id com.vaseltior \
--docset-feed-name "%PROJECT Documentation" \
--docset-feed-url "http://vaseltior.github.com/LP-Simple/%DOCSETATOMFILENAME" \
--docset-package-url  "http://vaseltior.github.com/LP-Simplex/%DOCSETPACKAGEFILENAME" \
--publish-docset \
--no-create-html \
-h \
-d \
-n \
-u \
--keep-undocumented-objects \
--keep-undocumented-members \
--search-undocumented-doc \
--output docs AboundingNest/AboundingNest \

