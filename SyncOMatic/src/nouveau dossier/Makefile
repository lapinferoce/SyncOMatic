.SUFFIXES: .erl .beam

.erl.beam:
	erlc -W $<

ERL = erl -boot start_clean
#MODS = module1 module2 module3

#all: compile
#	${ERL} -pa '/home/joe/.../this/dir' -s module1 start

#compile: ${MODS:%=%.beam}

#clean:
#	rm -rf *.beam erl_crash.dump

# -boot start_clean

PATH=./
MODS=client-test crawl md5 serialize misc
MODS_PATH=$(addprefix $(PATH),$(MODS))


all: compile
	${ERL} -pa '.' -s ./src/client-test start

compile: ${MODS_PATH:%=%.beam}

clean:
	rm -rf ./src/*.beam erl_crash.dump
