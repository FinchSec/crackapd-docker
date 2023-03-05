FROM finchsec/kali:base
# Use statically compiled asleap
ARG ASLEAP_BIN="/usr/local/bin/asleap"
COPY --from=finchsec/asleap:static /usr/bin/asleap "${ASLEAP_BIN}"
COPY --from=finchsec/asleap:static /usr/bin/genkeys /usr/local/bin/genkeys
# Install crackapd and hostapd-mana
ARG CRACKAPD_CONF="/usr/local/etc/crackapd.conf"
ARG CRACKAPD_PY="/usr/local/bin/crackapd.py"
#hadolint ignore=DL3008
RUN apt-get update && \
	apt-get install wget 2to3 hostapd-mana python3 ca-certificates --no-install-recommends -y && \
    wget -q https://github.com/sensepost/hostapd-mana/raw/master/crackapd/crackapd.py -O "${CRACKAPD_PY}" && \
    2to3 -w "${CRACKAPD_PY}" && \
	chmod +x "${CRACKAPD_PY}" && \
    wget -q https://github.com/sensepost/hostapd-mana/raw/master/crackapd/crackapd.conf -O "${CRACKAPD_CONF}" && \
	sed -i 's/mana-toolkit/hostapd-mana/g' "${CRACKAPD_CONF}" && \
	sed -i "s,THEPATH + str('crackapd.conf'),'${CRACKAPD_CONF}'," "${CRACKAPD_CONF}" && \
    sed -i "s,/usr/bin/asleap,${ASLEAP_BIN}," "${CRACKAPD_CONF}" && \
    apt-get purge 2to3 wget ca-certificates -y && \
    apt-get autoremove -y && \
    apt-get autoclean && \
	rm -rf /var/lib/dpkg/status-old /var/lib/apt/lists/*