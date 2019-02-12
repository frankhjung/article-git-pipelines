#!/usr/bin/make

.SUFFIXES:
.SUFFIXES: .md .html

.md.html:
	@pandoc --css article.css --to html4 --output $@ --self-contained --standalone --section-divs $<

.PHONY: clean
clean:
	@$(RM) -rf README.html
