# Read Me First

# TourGuider
RESTful API services for interacting with Tour Guider system

# Installation

1. [x] JDK (8 and above)
2. [x] MongoDB
3. [x] Git _(optional)_

## Dependent tools and frameworks used

1. [ ] Springboot/Spring-data
2. [ ] Spring Security
3. [ ] JWT http://jwt.io
4. [ ] Lombok

# Getting Started

## How to run this project?

1. Install JDK from [here](https://www.oracle.com/java/technologies/downloads/ )<br>
   **_Note: You can also install other variants of JDK like OpenJDK/Azul/Red Hat etc. instead of Oracle's_**
2. Install react related dependencies on your system from [here](https://react.dev/learn/start-a-new-react-project).
3. Clone this project
4. Open a terminal or command prompt and change directory to the `tourguider` directory

```agsl
cd tourguider
```

5. Now build the project
    1. By running below command if you're on a windows based system
   ```agsl
   gradlew.bat build
    ```
    2. Else run below command if you're using unix based system
   ```agsl
   ./gradlew build
   ```
6. Edit [application.properties](src/main/resources/application.properties) and change the value of setting `photos.file.storage.path` to a directory path local to your system for storing uploaded pictures. 
7. Run the springboot application using below command:

```agsl
java -jar build/libs/tourguider-0.0.1-SNAPSHOT.jar 
```
Note: If the above jar doesn't exist, probably the version might have changed, replace with the jar having similar name
pattern that is present on relative path: `build/libs`
8. Alternatively you can use below command and skip the above steps of building project
```agsl
./gradlew bootRun
```
Note: Replace <PATH> with the actual absolute path where the `secrets.properties` file is created.
9. Once the server is up, then you shall find a message similar to this:

```agsl
Started TourGuiderApplication in x.xxx seconds
```
