FROM amazoncorretto:21-alpine

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app
COPY run-java.sh .
RUN chmod +x run-java.sh
RUN sed -i 's/#networkaddress.cache.ttl=.*/networkaddress.cache.ttl=60/' $JAVA_HOME/conf/security/java.security

USER appuser

EXPOSE 8080
ENTRYPOINT ["sh", "./run-java.sh"]