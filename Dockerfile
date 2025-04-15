# Use the official Swift image for Linux
FROM swift:6.0

# Set the working directory
WORKDIR /app

# Copy the repository into the container
COPY . .

# Run tests
CMD ["swift", "test"]
