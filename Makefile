all: mc-kubelet-extra-labels.yaml

clean:
	rm -f mc-*-fragment.yaml

BASE64=/usr/bin/base64 -w0
ENVSUB=/usr/bin/envsubst
INDENT_OVERRIDE=sed 's/^/            /'
INDENT_UNIT=sed 's/^/          /'

mc-%-override-fragment.yaml: 20-extra-labels-infra.conf mc-override-template.yaml
	UNIT=$*.service CONTENTS=$$($(INDENT_OVERRIDE) $<) OVERRIDENAME=$< \
		$(ENVSUB) '$$UNIT $$CONTENTS $$OVERRIDENAME' <mc-override-template.yaml >$@

mc-container-mount-ns-service-fragment.yaml: container-mount-namespace.service mc-unit-template.yaml
	UNIT=$< CONTENTS=$$($(INDENT_UNIT) $<) \
		$(ENVSUB) '$$UNIT $$CONTENTS' <mc-unit-template.yaml >$@

mc-%-tool-fragment.yaml: % mc-file-template.yaml
	PATH=/usr/local/bin/$* MODE=$$(printf "%d" 0755) CONTENTS=$$($(BASE64) $<) \
		$(ENVSUB) '$$PATH $$MODE $$CONTENTS' <mc-file-template.yaml >$@

mc-files-fragment.yaml: mc-files-section-header.yaml mc-extractExecStart-tool-fragment.yaml mc-addExtraLables-tool-fragment.yaml
	cat $^ >$@

mc-systemd-fragment.yaml: mc-systemd-section-header.yaml mc-kubelet-override-fragment.yaml
	cat $^ >$@

mc-kubelet-extra-labels.yaml: mc-kubelet-extra-labels-header.yaml mc-files-fragment.yaml mc-systemd-fragment.yaml
	cat $^ >$@
