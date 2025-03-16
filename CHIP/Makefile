all:	clean comp run waveverdi

test:   comp run

clean:
	\rm -rf simv* csrc* *.log *.fsdb *.rc *.key verdi_config_file verdiLog *.conf
comp:
	vcs -f build.cud -sverilog -kdb +vcs+fsdbon
	
run:
	qrsh -V -cwd -b y -q sim_light ./simv 2>&1 | tee log
	#qrsh -V -cwd -b y -q sim_light ./simv +ntb_random_seed_automatic 2>&1 | tee log
waveverdi: 	
	verdi -ssf novas.fsdb
coverage:
	verdi -cov -covdir simv.vdb