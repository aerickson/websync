# I have issue when build from empty node_modules
# so, copy existing node_modules is the trick :)
FROM furier/websync:latest as builder
WORKDIR /build
COPY . .
RUN cp -rf /src/node_modules ./
RUN npm install
RUN npm run napa
RUN npm run build-dist
WORKDIR /build/dist
RUN cp -rf /src/node_modules /build/dist
RUN npm install

FROM node:0.12-slim
WORKDIR /src
# ENV TZ=Asia/Jakarta
RUN echo "deb http://archive.debian.org/debian/ jessie main" > /etc/apt/sources.list \
    && echo "deb http://archive.debian.org/debian-security/ jessie/updates main" >> /etc/apt/sources.list \
    && echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99ignore-valid-until \
    && apt-get update \
    && apt install -y --force-yes \
        rsync sshpass cron \
        openssh-client \
        tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p ~/.ssh \
    && chmod 700 ~/.ssh \
    && ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -q -N "" \
    && echo "Host *\n\tStrictHostKeyChecking no\n\tIdentityFile /root/.ssh/id_rsa" > /root/.ssh/config
COPY --from=builder /build/dist /src

ENTRYPOINT []
CMD ["node", "server.js"]
