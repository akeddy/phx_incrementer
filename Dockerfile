# Use an official Elixir runtime as a parent image.
#FROM elixir:latest
FROM elixir:otp-25

MAINTAINER akeddy

ARG MIX_ENV
ARG DATABASE_URL
ARG POOL_SIZE
ARG SECRET_KEY_BASE
ARG PORT

RUN apt-get update && \
  apt-get install -y postgresql-client

# Create app directory and copy the Elixir projects into it.
RUN mkdir /app
COPY increment/ /app
WORKDIR /app

# Install Hex package manager.
RUN mix local.hex --force

# install rebar
RUN mix local.rebar --force

RUN echo "America/Halifax" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

RUN mix deps.get --only-prod

# Compile the project.
RUN mix do compile

# RUN mix ecto.create
# RUN mix ecto.migrate
