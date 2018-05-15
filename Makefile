PREFIX=/usr/local
TASK_DONE = echo -e "\n✓ $@ done\n"
EXEC_FILES=mongodb-info.sh

.PHONY: test

all:
	@echo "usage: make install"
	@echo "       make reinstall"
	@echo "       make uninstall"
	@echo "       make test"

help:
	$(MAKE) all
	@$(TASK_DONE)

install:
	install -m 0755 $(EXEC_FILES) $(PREFIX)/bin
	@$(TASK_DONE)

uninstall:
	test -d $(PREFIX)/bin && \
	cd $(PREFIX)/bin && \
	rm -f $(EXEC_FILES)
	@$(TASK_DONE)

reinstall:
	@curl -s https://raw.githubusercontent.com/arzzen/mongodb-info/master/mongodb-info.sh > mongodb-info.sh
	$(MAKE) uninstall && \
	$(MAKE) install
	@$(TASK_DONE)

test:
	tests/commands_test.sh
	@$(TASK_DONE)
