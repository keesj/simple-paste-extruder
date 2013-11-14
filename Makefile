all: extruder_print_all.stl extruder_print_base.stl extruder_print_big_pinion.stl extruder_print_small_pinion.stl extruder_view.stl extruder.scad MCAD
	
%.stl:%.scad
	@echo working on $<
	openscad -o $@ $<
MCAD:
	git submodule init
	git submodule update
clean:
	rm -rf *.stl
