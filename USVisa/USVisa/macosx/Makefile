files = \
	../ViewController.m \
	../BatchPDFParser.m \
	../NSURLConnectionDirectDownload.m \
	../DirectDownloadDelegate.m \
	../main-cli.m

all: build run

build:
	clang -o USVisaTest -DTESTING -framework Foundation -lz $(files)

run:
	./USVisaTest 20121456171
