# Stage 1: Build the Executable JAR using Java 21
FROM maven:3.9.6-eclipse-temurin-21-alpine AS build
WORKDIR /app

# Cache dependencies to speed up future builds
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and build the package
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Lightweight Runtime Environment
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Copy the built JAR from the build stage
COPY --from=build /app/target/*.jar app.jar

# Dynamic Port Binding (Render assigns $PORT at runtime)
ENV PORT=8080
EXPOSE ${PORT}

# Enforce strict JVM memory limits to fit within Render's free 512MB RAM limit
ENV JAVA_OPTS="-Xmx320m -Xms256m -Xss256k -XX:+UseContainerSupport -XX:+ExitOnOutOfMemoryError"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]