## Getting Started

Follow these steps to clone the repository and set up the project:

### Prerequisites
1. Ensure you have the following installed:
    - Java Development Kit (JDK) 8 or higher
    - Apache Tomcat server
    - A compatible IDE (e.g., IntelliJ IDEA, Eclipse)
    - Git

### Cloning the Repository
1. Open a terminal or command prompt.
2. Navigate to the directory where you want to clone the project.
3. Run the following command:
    ```bash
    git clone https://github.com/sahilverse/aao-news.git
    ```
4. Navigate into the project directory:
    ```bash
    cd aao-news
    ```

### Setting Up the Project
1. Open the project in your IDE.
2. Configure the Tomcat server in your IDE.
3. Import the project as a Maven project (if applicable).
4. Build the project to resolve dependencies.
5. Add db.properties inside src/main/resources

### Running the Application
1. Deploy the project to the Tomcat server.
2. Start the server.
3. Open your browser and navigate to `http://localhost:8080/aao-news` (or the configured context path).

### Contributing
1. Create a new branch for your feature or bug fix:
    ```bash
    git checkout -b feature/your-feature-name
    ```
2. Make your changes and commit them:
    ```bash
    git add .
    git commit -m "Description of your changes"
    ```
3. Push your branch to the repository:
    ```bash
    git push origin feature/your-feature-name
    ```
4. Create a pull request for review.

### Notes
- Ensure you follow the team's coding standards.
- Keep your branch up-to-date with the `main` branch to avoid conflicts.



