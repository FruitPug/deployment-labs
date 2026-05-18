FROM maven:3.9.15-eclipse-temurin-17 AS builder

WORKDIR /build

COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src

RUN mvn package -DskipTests


FROM gcr.io/distroless/java17-debian13@sha256:2da17315bae0e8c052046625fa444a41f4da1b148253a2ad013dd18cc5e7a55e

WORKDIR /app

COPY --from=builder /build/target/mywebapp-1.0-SNAPSHOT.jar app.jar

CMD ["app.jar"]
