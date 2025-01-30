# Use Eclipse Temurin JDK 17 as the base image for dependencies
FROM eclipse-temurin:17-jdk-jammy AS deps

WORKDIR /build

# Install dos2unix to handle Windows line endings
RUN apt-get update && apt-get install -y dos2unix

# Copy and convert mvnw to Unix format
COPY mvnw mvnw
RUN dos2unix mvnw && chmod +x mvnw

# Copy Maven Wrapper and Pom file
COPY .mvn/ .mvn/
COPY pom.xml pom.xml

# Download dependencies in offline mode
RUN bash ./mvnw dependency:go-offline -DskipTests

################################################################################

# Packaging Stage
FROM deps AS package

WORKDIR /build

# Copy application source code
COPY ./src src/

# Build the application JAR
RUN bash ./mvnw package -DskipTests && \
    mv target/$(bash ./mvnw help:evaluate -Dexpression=project.artifactId -q -DforceStdout)-$(bash ./mvnw help:evaluate -Dexpression=project.version -q -DforceStdout).jar target/app.jar

################################################################################

# Extraction Stage
FROM package AS extract

WORKDIR /build

# Extract the JAR file using Spring Boot Layered JAR Tools
RUN java -Djarmode=layertools -jar target/app.jar extract --destination target/extracted

################################################################################

# Final Runtime Stage
FROM eclipse-temurin:17-jre-jammy AS final

# Create a non-root user
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

USER appuser

# Set application directory
WORKDIR /app

# Copy extracted application layers
COPY --from=extract /build/target/extracted/dependencies/ ./
COPY --from=extract /build/target/extracted/spring-boot-loader/ ./
COPY --from=extract /build/target/extracted/snapshot-dependencies/ ./
COPY --from=extract /build/target/extracted/application/ ./

# Expose application port
EXPOSE 8080

# Set the entry point
ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]
