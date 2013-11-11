all: extruder_print.stl extruder_view.stl extruder.scad MCAD
	
%.stl:%.scad
	openscad -o $@ $<
MCAD:
	git submodule init
	git submodule update
clean:
	rm -rf *.stl
