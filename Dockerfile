# syntax=docker/dockerfile:1

########## Stage 1: Build ##########
FROM eclipse-temurin:17-jdk-jammy AS builder

WORKDIR /build

COPY .mvn/ .mvn
COPY mvnw pom.xml ./

RUN --mount=type=cache,target=/root/.m2 \
    ./mvnw dependency:go-offline -B

COPY src ./src

RUN --mount=type=cache,target=/root/.m2 \
    ./mvnw -DskipTests package

########## Stage 2: Runtime ##########
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app
COPY --from=builder /build/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]

