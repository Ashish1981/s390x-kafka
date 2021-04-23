FROM docker.io/ibmjava


ARG kafka_version=2.7.0
ARG scala_version=2.13
ARG glibc_version=2.31-r0
ARG vcs_ref=unspecified
ARG build_date=unspecified
# ARG zookeeper_version=3.7.0

LABEL org.label-schema.name="kafka" \
      org.label-schema.description="Apache Kafka" \
      org.label-schema.build-date="${build_date}" \
      org.label-schema.vcs-url="https://github.com/Ashish1981/s390x-kafka" \
      org.label-schema.vcs-ref="${vcs_ref}" \
      org.label-schema.version="${scala_version}_${kafka_version}" \
      org.label-schema.schema-version="1.0" \
      maintainer="Ashish1981"

ENV KAFKA_VERSION=$kafka_version \
    SCALA_VERSION=$scala_version \
    # ZOOKEEPER_VERSION=${zookeeper_version} \
    KAFKA_HOME=/opt/kafka \
    GLIBC_VERSION=$glibc_version \
    PATH=${PATH}:${KAFKA_HOME}/bin

ADD /*.sh /tmp/
USER root
RUN apt update && apt full-upgrade -y && apt install -y \
    supervisor \
    curl \
    jq \
    docker \
    wget \
    make \
    build-essential  \
    && chmod a+x /tmp/*.sh \
    && cp -rf /tmp/*.sh /usr/bin/ \
    && download-kafka.sh \
    && tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
    && rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
    && ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME} \
    # && tar xfz /tmp/zookeeper-${ZOOKEEPER_VERSION}-bin.tgz -C /opt \
    # && rm /tmp/zookeeper-${ZOOKEEPER_VERSION}.tgz \
    # && 
    && chmod a+w /var/log/supervisor

COPY overrides /opt/overrides

VOLUME ["/kafka"]


#ADD scripts/start-kafka.sh /usr/bin/start-kafka.sh

# Supervisor config
ADD supervisor/kafka.conf supervisor/zookeeper.conf /etc/supervisor/conf.d/

# 2181 is zookeeper, 9092 is kafka
EXPOSE 2181 9092

CMD ["supervisord", "-n"]
