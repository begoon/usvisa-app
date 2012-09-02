include $(GNUSTEP_MAKEFILES)/common.make

TOOL_NAME = USVisa
USVisa_OBJC_FILES = \
	../ViewController.m \
	../BatchPDFParser.m \
	../NSURLConnectionDirectDownload.m \
	../DirectDownloadDelegate.m \
	../main-cli.m
USVisa_TOOL_LIBS = -lz
ADDITIONAL_OBJCFLAGS = -DTESTING
CC = clang

include $(GNUSTEP_MAKEFILES)/tool.make

run:
	./obj/USVisa 20121456171
