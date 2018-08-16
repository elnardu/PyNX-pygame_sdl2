
all: .bootstrapped buildPyNX


.bootstrapped:
	git submodule update --init
	mkdir build
	@touch .bootstrapped

PATCHDIR := $(CURDIR)/patch

# this should be python 3
PYTHON := python3

patchPygame: 
	rsync -a $(PATCHDIR)/pygame_sdl2/ $(CURDIR)/pygame_sdl2/ && touch patchPygame

buildPygame: patchPygame 
	cd $(CURDIR)/pygame_sdl2/ && $(PYTHON) setup.py && cd .. && touch buildPygame

patchPyNX:
	rsync -a $(PATCHDIR)/PyNX/ $(CURDIR)/PyNX/ && touch patchPyNX

prebuildPyNX: patchPyNX
	$(MAKE) -C $(CURDIR)/PyNX/python_build extractedPY patchPY && touch prebuildPyNX

PYGAME_BUILDDIR := $(CURDIR)/pygame_sdl2/build_mod
PYTHON_BUILDDIR := $(CURDIR)/PyNX/python_build/Python-3.5.3
injectPythonModules: prebuildPyNX buildPygame
	cp -r $(PYGAME_BUILDDIR)/c_files $(PYTHON_BUILDDIR)/Modules/pygame_sdl2
	cp $(CURDIR)/pygame_sdl2/src/pygame_sdl2/pygame_sdl2.h $(PYTHON_BUILDDIR)/Modules/pygame_sdl2/
	
	PYTHON_BUILDDIR=$(PYTHON_BUILDDIR) PYGAME_BUILDDIR=$(PYGAME_BUILDDIR) $(CURDIR)/pythonSetupPygame.sh
	touch injectPythonModules

buildPyNX: injectPythonModules
	$(MAKE) -C $(CURDIR)/PyNX
	$(MAKE) -C $(CURDIR)/PyNX dist
	cp -r $(CURDIR)/PyNX/build/PyNX/* $(CURDIR)/build
	cp -r $(CURDIR)/pygame_sdl2/build_mod/pygame_sdl2 $(CURDIR)/build/ 

clean:
	rm -f patchPygame patchPyNX buildPygame prebuildPyNX injectPythonModules
	$(MAKE) -C $(CURDIR)/PyNX clean
	git submodule foreach --recursive git reset --hard
	rm -rf build/ .bootstrapped