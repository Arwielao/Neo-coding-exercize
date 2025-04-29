# Stage 1: compile release
FROM elixir:1.14.3 AS builder
WORKDIR /app

# Устанавливаем системные зависимости и hex & rebar
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential git curl ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    mix local.hex --force && \
    mix local.rebar --force

# Копируем mix-файлы и фавиксы
COPY mix.exs mix.lock ./
COPY config config

# Скачиваем deps
RUN mix deps.get --only prod && mix deps.compile

# Копируем исходники и собираем release
COPY lib lib
COPY priv priv
RUN MIX_ENV=prod mix compile
RUN MIX_ENV=prod mix release --overwrite

# Stage 2: запуск release
FROM debian:bullseye-slim AS runner
WORKDIR /app

# Устанавливаем необходимые зависимости для Erlang/OTP (glibc-библиотеки)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      openssl ca-certificates curl \
      libncurses6 libstdc++6 libgcc1 && \
    rm -rf /var/lib/apt/lists/*

# Устанавливаем и генерируем локали UTF-8
RUN apt-get update && \
    apt-get install -y --no-install-recommends locales && \
    sed -i 's/# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

# Копируем артефакты релиза
COPY --from=builder /app/_build/prod/rel/api ./

ENV MIX_ENV=prod \
    REPLACE_OS_VARS=true \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

CMD ["bin/api", "start"]