# Use the official Swift image for Linux
FROM swift:6.0

# Set the working directory
WORKDIR /app

# Copy the project files into the container
COPY . .

# Clean up any existing build artifacts
RUN rm -rf .build

# Resolve dependencies
RUN swift package resolve

# Run the tests
CMD ["swift", "test"]
