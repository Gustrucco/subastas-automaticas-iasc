# Use an official Python runtime as a parent image
FROM elixir

# Set the working directory to /app
WORKDIR /

# Copy the current directory contents into the container at /app
ADD . /

ENV ip 0.0.0.0

# Run app.py when the container launches
CMD echo "Starting..." && iex --name balancer@${ip} -S mix
