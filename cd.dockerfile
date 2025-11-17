# ===== BUILDER =====
FROM eclipse-temurin:21-jdk AS builder

WORKDIR /app

# Copier Maven Wrapper + configuration
COPY .mvn .mvn
COPY mvnw .
RUN sed -i 's/\r$//' mvnw && chmod +x mvnw

# Copier pom.xml (pour le cache)
COPY pom.xml .

# Pré-télécharger les dépendances Maven (accélère les builds)
RUN ./mvnw dependency:go-offline -B

# Copier le code
COPY src ./src

# Build du jar (sans tests pour le TP)
RUN ./mvnw clean package -DskipTests

# ===== PRODUCTION =====
FROM eclipse-temurin:21-jre AS production

WORKDIR /app

# Copier le jar depuis le builder
COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

# Démarrage de l'app Spring Boot
CMD ["java", "-jar", "app.jar"]
