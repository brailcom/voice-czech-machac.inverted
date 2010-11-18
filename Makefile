# Configuration

festival_voices_path = /usr/share/festival/voices

# End of configuration

voice_name := machac
package := voice-czech-$(voice_name)
version := 0.1

destdir = $(festival_voices_path)/czech/czech_$(voice_name)

.PHONY: all install uninstall dist dist-src dist-bin lpc-files

all: festvox/czech_$(voice_name).scm lpc-files group/$(voice_name).group

lpc-files: $(patsubst wav/%.wav, lpc/%.lpc, $(wildcard wav/*.wav))
lpc/$(voice_name)0000.lpc: wav/$(voice_name)0000.wav pm/$(voice_name)0000.pm
	mkdir -p lpc
	./tools/make_lpc $<
lpc/%.lpc: wav/%.wav pm/%.pm etc/powfacts
	./tools/make_lpc $<

festvox/czech_$(voice_name).scm: festvox/czech_$(voice_name).scm.in
	sed 's/DESTDIR/$(subst /,\/,$(destdir))/' $< > $@

group/$(voice_name).group: lpc-files
	mkdir -p group
	festival -b make-group.scm

clean:
	rm -rf $(package)-$(version) $(package)-$(version).tar
	rm -rf $(package)-bin-$(version) $(package)-bin-$(version).tar
	rm -f $(package)-$(version).tar.gz $(package)-bin-$(version).tar.gz
	rm -f festvox/czech_$(voice_name).scm

distclean: clean
	rm -f lpc/* group/*

maintainer-clean: distclean

install: group/$(voice_name).group festvox/czech_$(voice_name).scm
	install -d $(destdir)
	install -d $(destdir)/festvox
	install -m 644 festvox/czech_$(voice_name).scm $(destdir)/festvox/
	install -d $(destdir)/group
	install -m 644 group/$(voice_name).group $(destdir)/group/

uninstall:
	rm -f $(destdir)/festvox/czech_$(voice_name).scm $(destdir)/group/$(voice_name).group
	-rmdir $(destdir)/festvox
	-rmdir $(destdir)/group

dist: clean dist-src dist-bin

dist-src:
	rm -rf $(package)-$(version) $(package)-$(version).tar $(package)-$(version).tar.gz
	mkdir $(package)-$(version)
	cp -a COPYING INSTALL Makefile README* *.scm dic doc festvox pm tools wav $(package)-$(version)/
	mkdir $(package)-$(version)/group
	mkdir $(package)-$(version)/lpc
	for d in `find $(package)-$(version) -name .git`; do rm -r $$d; done
	tar cf $(package)-$(version).tar $(package)-$(version)
	gzip -9 $(package)-$(version).tar

dist-bin: all
	rm -rf $(package)-bin-$(version) $(package)-bin-$(version).tar $(package)-bin-$(version).tar.gz
	mkdir $(package)-bin-$(version)
	cp -a COPYING INSTALL README* festvox group $(package)-bin-$(version)/
	sed '/festival -b make-group.scm/d' Makefile > $(package)-bin-$(version)/Makefile
	for d in `find $(package)-bin-$(version) -name .git`; do rm -r $$d; done
	tar cf $(package)-bin-$(version).tar $(package)-bin-$(version)
	gzip -9 $(package)-bin-$(version).tar
