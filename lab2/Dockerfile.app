FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /build

COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src

RUN mvn package -DskipTests


FROM gcr.io/distroless/java17-debian13

WORKDIR /app

COPY --from=builder /build/target/mywebapp-1.0-SNAPSHOT.jar app.jar

CMD ["app.jar"]
