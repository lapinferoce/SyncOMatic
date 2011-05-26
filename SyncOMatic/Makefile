
ERL = erl -boot start_clean
ERLC = erlc -W
#MODS = module1 module2 module3

#all: compile
#	${ERL} -pa '/home/joe/.../this/dir' -s module1 start

compile: ${MODS:%=%.beam}

#clean:
#	rm -rf *.beam erl_crash.dump

# -boot start_clean

PATH_SRC=./src/
MODS=clientTest server client crawl utilmisc md5 serialize fileset fileutil changeset net confClient confServer clock
MODS_PATH=$(addprefix $(PATH_SRC),$(MODS))


test: compile
	${ERL} -pa '.' -s clientTest start

client: compile
	${ERL} -pa '.' -s client start
server: compile
	${ERL} -pa '.' -s server start

compile: ${MODS_PATH:%=%.beam}

clean:
	rm -rf *~ ./src/*~ *.beam erl_crash.dump

.SUFFIXES: .erl .beam

.erl.beam:
	${ERLC} -W $<

