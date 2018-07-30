# Use an official Python runtime as a parent image
FROM elixir

# Set the working directory to /app
WORKDIR /

# Copy the current directory contents into the container at /app
ADD . /

ENV ip 0.0.0.0
ENV name worker

# Run app.py when the container launches
CMD echo "Starting..." && echo $'InitWorker.start_worker' | iex --name ${name}@${ip} -S mix
