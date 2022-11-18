#
# Select Base image, we choose a Nodejs base 
# because it has already all the ingredients for 
# our Nodejs app
#
#FROM    dockerfile/nodejs
FROM node:11

#
# Bundle our app source with the container, we
# could also be fetching the code from a git 
# repo, or really anything else.
#
RUN npm install -g bower grunt-cli

#RUN mkdir /src/
WORKDIR /src

#
# Install app dependencies - Got to install them 
# all! :)
#

#RUN npm config set registry https://npm-cache.layer0.eu.org
RUN npm set cache /src/.npm --global
RUN apt install libc-dev 
RUN (test -e /src || mkdir /src)|| true  && apt install python3 make gcc
COPY app assets default.wsdata.json gulpfile.js server.js test lib bower.json /src/

COPY package.json /src
RUN npm pack --dry-run 
WORKDIR /src


#ADD ./ /src


#RUN apk add musl-dev
RUN ( bash -c ' [[ -z "$NPM_REGISTRY" ]] || npm set registry $NPM_REGISTRY ' ) || true 
RUN npm i --package-lock-only && npm audit fix --force
RUN npm install && echo INSTALLED_PKG 
RUN npm audit fix && echo AUDIT DONE

RUN npm i -g gulp-cli grunt-cli
RUN bower install --allow-root
RUN gulp
RUN gulp dist
run ls
RUN npm build
RUN ls
run echo done 
#RUN gulp
#npm install

# 
# Which ports you want to be exposing from this 
# container
#

EXPOSE  3000

#
# Specify the runtime (node) and the source to 
# be run
#
CMD ["node", "/src/server.js"]

#
# Note: You can do pretty much anything you 
# would do in a command line, using the `RUN` 
# prefix 
#
